# Задание
1. Попасть в систему без пароля несколькими способами.
2. Установить систему с LVM, после чего переименовать VG.
3. Добавить модуль в initrd.

# Решение

## 1) Попасть в систему без пароля
#### Способ 1. init=/bin/sh
- В конце строки начинающейся с `linux16` добавляем `init=/bin/sh` и нажимаем **сtrl-x** для загрузки в систему
- Перемонтировать ее в режим Read-Write:
```sh
# mount -o remount,rw /
```

#### Способ 2. rd.break
- В конце строки начинающейся с `linux16` добавляем `rd.break` и нажимаем **сtrl-x** для загрузки в систему
- Попадаем в **emergency mode**. Наша корневая файловая система смонтирована (режиме Read-Only):
```sh
# mount -o remount,rw /sysroot
# chroot /sysroot
# passwd root
# touch /.autorelabel
```
- После чего можно перезагружаться и заходить в систему с новым паролем.

#### Способ 3. rw init=/sysroot/bin/sh
- В строке начинающейся с `linux16` заменяем `ro` на `rw init=/sysroot/bin/sh` и нажимаем **сtrl-x** для загрузки в систему

## 2) Установить систему с LVM, после чего переименовать VG
Первым делом посмотрим текущее состояние системы:
```sh
# vgs
VG #PV #LV #SN Attr VSize VFree
centos 1 2 0 wz--n- <38.97g 0
```
Нас интересует вторая строка с именем `Volume Group`. Приступим к переименованию:
```sh
# vgrename centos centos_new
Volume group "centos" successfully renamed to "centos_new"
```
 - Правим `/etc/fstab`, `/etc/default/grub`, `/boot/grub2/grub.cfg`. Везде заменяем старое название на новое.
 - Пересоздаем **initrd image**, чтобы он знал новое название **Volume Group**
```sh
# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
...
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```
 - После чего можем перезагружаться и если все сделано правильно успешно грузимся с новым именем Volume Group и проверяем:
```sh
# vgs
VG #PV #LV #SN Attr VSize VFree
centos_new 1 2 0 wz--n- <38.97g 0
```

## 3) Добавить модуль в initrd

Скрипты модулей хранятся в каталоге `/usr/lib/dracut/modules.d/`. Для того чтобы добавить свой модуль создаем там папку с именем 01test:
```sh
# mkdir /usr/lib/dracut/modules.d/01test
```
В нее поместим два скрипта:
1. `module-setup.sh` - который устанавливает модуль и вызывает скрипт `test.sh`
```sh
#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
```
2. `test.sh` - вызываемый скрипт
```sh
#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
```
Пересобираем образ initrd
```sh
 mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
 ```
или
```sh
# dracut -f -v
```
Можно проверить/посмотреть какие модули загружены в образ:
```sh
# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
test
```
После чего можно пойти двумя путями для проверки:
 - Перезагрузиться и руками выключить опции `rgbh` и `quiet` и увидеть вывод
 - Либо отредактировать `grub.cfg` убрав эти опции

В итоге при загрузке будет пауза на 10 секунд и вы увидите пингвина в выводе терминала
