<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&height=250&section=header&text=NotDev%203x-ui%20Stealth&fontSize=50&animation=fadeIn&fontAlignY=38&desc=Support%20non-persistent%20storage&descAlignY=60&descAlign=50" alt="Header Animation" />
</p>

<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=20&pause=1000&color=3B82F6&center=true&vCenter=true&width=600&lines=3x-ui%20Smart%20Reverse%20Proxy;Stealth%20System%20with%20Nginx;Dockerized%203x-ui%20with%20Dynamic%20Ports;Automated%20database%20configuration;Support%20non-persistent%20storage" alt="Typing SVG" />
</p>


---



## یک نسخه شخصی‌سازی شده از پنل **3x-ui** بهینه شده برای اجرا روی پلتفرم‌های ابری بدون حافظه دائمی.
---


<div dir="rtl">



## 📝 خلاصه تغییرات و ویژگی‌های فنی

### ۱. استراتژی ذخیره‌سازی ابری (Git-As-Database)
*  پیاده‌سازی اسکریپت هوشمند در `entrypoint.sh` برای استفاده از یک مخزن خصوصی (Private Repo) گیت‌هاب به عنوان دیتابیس.
* **بهینه‌سازی Snapshot:** استفاده از متد `commit --amend` و `force-push` برای نگه‌داشتن تاریخچه مخزن در یک کامیت واحد. این کار از حجیم شدن مخزن دیتابیس بر اثر آپدیت‌های مداوم جلوگیری می‌کند.

### ۲. وب‌سرور چندمنظوره (Multi-Protocol Nginx)
پشتیبانی جامع و پیکربندی `nginx.conf` برای هندل کردن همزمان:
* ‏**WebSocket (WS)** و **HTTPUpgrade** (بهینه‌تر از WS برای اختلالات شبکه).
* ‏**XHTTP:** در تمام مدهای **packet-up** و **stream-up** با قابلیت **request_buffering off**.
* ‏**gRPC:** در پورت و مسیر مجزا.
* ‏**مسیردهی هوشمند (Regex Routing):** استفاده از الگوهای منظم برای هدایت ترافیک به پورت‌های داخلی بر اساس مسیر URL (مثلاً `/api/v8443/` به پورت ۸۴۴۳)، بدون نیاز به تغییر کد Nginx برای اینباندهای جدید.

### ۳. استتار و شخصی‌سازی (Cloaking & Branding)
* **صفحه فرود (Landing Page):** ادغام خودکار قالب **Bootstrap** برای نمایش یک سایت معتبر در صفحه اصلی جهت جلوگیری از شناسایی توسط سیستم‌های فیلترینگ (DPI).
* **تزریق هویت (Injection):** استفاده از `sub_filter` در Nginx برای تغییر داینامیک تایتل مرورگر و آیکون (Favicon) پنل بر اساس متغیر `CUSTOM_TITLE`.

### ۴. زیرساخت داکر و CI/CD
* ‏**Dockerization:** انتقال به **Custom Dockerfile** جهت کنترل کامل روی لایه‌های سیستم‌عامل.
* ‏**GitHub Actions:** پیاده‌سازی `docker-publish.yml` برای بیلد خودکار و انتشار در **GHCR** با قابلیت تگ‌گذاری نسخه.

---

## 🛠 راهنمای کامل راه‌اندازی پروژه از صفر (نسخه نهایی)

### مرحله ۱: آماده‌سازی در GitHub
1. **ساخت دو مخزن خصوصی (Private):**
   - مخزن اول: برای کدها و داکر (مثلاً `x-project`).
   - مخزن دوم: برای ذخیره دیتابیس (مثلاً `system-assets`) جهت نگهداری `x-ui.db`.
2. **ساخت توکن (PAT):** به Settings > Developer Settings بروید و یک توکن با دسترسی `repo` و `write:packages` بسازید.

### مرحله ۲: تنظیمات فایل‌های مخزن کد
پنج فایل زیر را در مخزن اول قرار دهید:
* ‏`Dockerfile` | `entrypoint.sh` | `nginx.conf` | `favicon.ico`
* ‏`.github/workflows/docker-publish.yml`


 ‏در **Settings > Actions > General** مخزن، دسترسی را روی **Read and write permissions** قرار دهید.

### مرحله ۳: بیلد و انتشار ایمیج
1. کد را Push کنید و در تب **Actions** منتظر تیک سبز بمانید.
2. در پروفایل خود بخش **Packages**، پکیج را باز کرده و در تنظیمات، وضعیت آن را **Public** کنید تا Koyeb به آن دسترسی داشته باشد.

### مرحله ۴: دپلوی در Koyeb
یک سرویس جدید ساخته و متغیرهای زیر را تنظیم کنید:
* ‏`GH_USER`: نام کاربری
* ‏`GH_REPO`: نام مخزن دیتابیس
* ‏`GH_TOKEN`: توکن PAT
* ‏`CUSTOM_TITLE`: نام دلخواه تب مرورگر
* ‏`PORT`: معمولا 8080
* ‏`PANEL_PATH`: (دلخواه - پیش‌فرض: /dashboard/
* ‏`SUB_PATH`: (دلخواه - پیش‌فرض: /sub/)
*‏ `API_PREFIX`: (دلخواه - پیش‌فرض: /api/v)
* ‏`SUB_PORT`: (دلخواه - پیش‌فرض: 2065


### مرحله ۵: تنظیمات دامنه و Cloudflare
1. در Koyeb دامنه شخصی را اضافه کنید.
2. در کلادفلر رکورد **CNAME** بزنید و وضعیت پروکسی را **نارنجی** کنید.
3. حالت SSL/TLS را حتماً روی **Full** بگذارید.

### مرحله ۶: تنظیمات داخل پنل 3x-ui
1. وارد پنل شوید: `https://domain.com/dashboard/`
2. در بخش **Subscription**: پورت را روی `2065` و مسیر را روی `/sub/` بگذارید.
مسیر سابسکریپشن در فایل nginx.cong قابل ویرایش است
3. **ساخت اینباند:**
   * ‏**Port:** مثلاً 8443.
   * ‏**Path:** طبق فرمت Regex: `/api/v8443/` (برای WS: `/api/v8443/?ed=2560`).
   * ‏**External Proxy:** دامنه خودتان، پورت 443 و TLS روشن.

### مرحله ۷: تنظیمات کلاینت (گوشی کاربر)
1. لینک سابسکریپشن را به برنامه (Karing یا v2rayNG) بدهید.
2. **نکته مخابرات:** اگر وصل نشد، در تنظیمات گوشی:
   * آدرس سرور را به یک **IP تمیز کلادفلر** تغییر دهید.
   * ‏**SNI** و **Host** حتماً دامنه خودتان باشد.
   * قابلیت **Fragment** را با مقادیر `10-20` فعال کنید.

---

## 📌 نکات کلیدی نگهداری
* **آپدیت دیتابیس:** دیتابیس هر ۵ دقیقه به گیت‌هاب فرستاده می‌شود. قبل از ری‌دپلوی، مطمئن شوید کامیت جدید در مخزن دیتابیس ثبت شده است.
* **امنیت:** به دلیل Private بودن مخازن و استفاده از Docker Registry، هیچ ردپایی از کدهای داخلی شما در اینترنت عمومی وجود ندارد.

**موفق باشی! 🚀**

</div>
