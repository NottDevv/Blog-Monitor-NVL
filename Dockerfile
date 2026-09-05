FROM ubuntu:22.04

# تنظیمات اولیه سیستم‌عامل
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran

# نصب ابزارهای مورد نیاز
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    wget \
    git \
    gettext-base \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# ساخت پوشه‌های مورد نیاز برای پنل و دیتابیس
RUN mkdir -p /etc/x-ui /usr/local/x-ui /var/log/nginx /db-backup

# ۱. دانلود و راه‌اندازی سایت استتار (قالب Bootstrap)
RUN rm -rf /usr/share/nginx/html/* \
    && git clone https://github.com/StartBootstrap/startbootstrap-creative.git /temp-site \
    && mv /temp-site/dist/* /usr/share/nginx/html/ \
    && rm -rf /temp-site

# ۲. نصب پنل 3x-ui (نسخه MHSanaei)
WORKDIR /usr/local/x-ui
RUN wget https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-amd64.tar.gz \
    && tar -zxvf x-ui-linux-amd64.tar.gz -C /tmp/ \
    && mv /tmp/x-ui/x-ui . \
    && mv /tmp/x-ui/bin . \
    && rm -rf /tmp/x-ui x-ui-linux-amd64.tar.gz \
    && chmod +x x-ui

# ۳. کپی کردن فایل‌های تنظیمات
COPY nginx.conf /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
COPY favicon.ico /usr/share/nginx/html/favicon.ico

# تنظیم دسترسی اجرایی به اسکریپت استارت
RUN chmod +x /entrypoint.sh

# تنظیمات نهایی پورت و مسیر اجرا
WORKDIR /usr/local/x-ui
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
