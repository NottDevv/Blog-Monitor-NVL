#!/bin/bash

# تنظیم متغیرهای محیطی (قابل تنظیم از Railway)
export PORT=${PORT:-8080}
export FINAL_TITLE=${CUSTOM_TITLE:-Web Monitor}
export PANEL_PATH=${PANEL_PATH:-/dashboard/}
export SUB_PATH=${SUB_PATH:-/sub/}
export SUB_PORT=${SUB_PORT:-2065}
export API_PREFIX=${API_PREFIX:-/api/v}

export DB_PATH="/etc/x-ui/x-ui.db"
export BACKUP_DIR="/db-backup"

# تنظیم هویت جعلی برای گیت
git config --global user.email "bot@example.com"
git config --global user.name "Auto Backup Bot"

echo ">>> Starting setup with GitHub Sync (Snapshot Mode)..."

# ----------------------------------------------------------------
# بخش 1: دانلود دیتابیس از مخزن گیت‌هاب
# ----------------------------------------------------------------
mkdir -p /etc/x-ui

if [ -n "$GH_TOKEN" ] && [ -n "$GH_REPO" ] && [ -n "$GH_USER" ]; then
    echo ">>> GitHub Config detected. Cloning backup repo..."
    rm -rf $BACKUP_DIR
    
    # آدرس مخزن با استفاده از توکن
    REPO_URL="https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/${GH_REPO}.git"
    
    # کلون کردن
    git clone "$REPO_URL" $BACKUP_DIR

    if [ -f "$BACKUP_DIR/x-ui.db" ]; then
        echo ">>> [OK] Previous database found! Restoring..."
        cp -f "$BACKUP_DIR/x-ui.db" "$DB_PATH"
    else
        echo ">>> [INFO] No database found in repo. Creating a fresh one..."
        mkdir -p $BACKUP_DIR
    fi
else
    echo ">>> [WARNING] GitHub variables not set! Data will be lost on restart."
fi

# لینک کردن دیتابیس
ln -sf "$DB_PATH" /usr/local/x-ui/x-ui.db

# ----------------------------------------------------------------
# بخش 2: تنظیمات Nginx و x-ui
# ----------------------------------------------------------------
cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf

sed -i "s|_TITLE_HERE_|$FINAL_TITLE|g" /etc/nginx/nginx.conf
sed -i "s|_PANEL_PATH_|$PANEL_PATH|g" /etc/nginx/nginx.conf
sed -i "s|_SUB_PATH_|$SUB_PATH|g" /etc/nginx/nginx.conf
sed -i "s|_SUB_PORT_|$SUB_PORT|g" /etc/nginx/nginx.conf
sed -i "s|_API_PREFIX_|$API_PREFIX|g" /etc/nginx/nginx.conf

echo "Configuring x-ui..."
cd /usr/local/x-ui
./x-ui setting -port 3000
./x-ui setting -webBasePath "$PANEL_PATH"

echo "Starting x-ui backend..."
./x-ui > /var/log/x-ui.log 2>&1 &

sleep 5

if pgrep -x "x-ui" > /dev/null; then
    echo "x-ui started successfully!"
else
    echo "ERROR: x-ui failed to start. Logs:"
    cat /var/log/x-ui.log
    exit 1
fi

# ----------------------------------------------------------------
# بخش 3: لوپ بکاپ‌گیری هوشمند (Force Push) روی گیت‌هاب
# ----------------------------------------------------------------
if [ -n "$GH_TOKEN" ]; then
    echo ">>> Starting background Git Sync process (5 minutes)..."
    (
        cd $BACKUP_DIR
        git config pull.rebase false
        
        while true; do
            sleep 300 # 5 دقیقه
            
            if [ -f "$DB_PATH" ]; then
                cp -f "$DB_PATH" "$BACKUP_DIR/x-ui.db"
                
                if [[ -n $(git status -s) ]]; then
                    echo ">>> Changes detected. Updating Snapshot on GitHub..."
                    git add x-ui.db
                    
                    if git rev-parse HEAD > /dev/null 2>&1; then
                        git commit --amend -m "Auto-backup: $(date)" --no-edit
                        git push -f origin main || git push -f origin master
                    else
                        git commit -m "First Backup: $(date)"
                        git push origin main || git push origin master
                    fi
                    echo ">>> Backup uploaded successfully!"
                fi
            fi
        done
    ) &
fi

# ----------------------------------------------------------------
# بخش 4: اجرای Nginx
# ----------------------------------------------------------------
echo ">>> Starting Nginx on port $PORT..."
nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
