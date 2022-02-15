# Домашнее задание

## Vagrant стенд для NFS

 - Vagrant up должен поднимать 2 виртуалки: сервер и клиент;
 - На сервер должна быть расшарена директория;
 - На клиента она должна автоматически монтироваться при старте (fstab или autofs);
 - В шаре должна быть папка upload с правами на запись;
 - Требования для NFS: NFSv3 по UDP, включенный firewall.
 - Настроить аутентификацию через KERBEROS (NFSv4)

## Тестовая среда:

Vagrantfile:
```bash
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"
  
  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfss" do |nfss|
    nfss.vm.network "private_network", ip: "192.168.50.10",
  virtualbox__intnet: "net1"
    nfss.vm.hostname = "nfss"
    nfss.vm.provision "shell", path: "nfss_script.sh"
  end

  config.vm.define "nfsc" do |nfsc|
    nfsc.vm.network "private_network", ip: "192.168.50.11",
  virtualbox__intnet: "net1"
    nfsc.vm.hostname = "nfsc"
    nfsc.vm.provision "shell", path: "nfsc_script.sh"
  end
end
```
## Файлы:
 - nfsc_script.sh
```bash
#/bin/bash

yum install nfs-utils -y # Установка вспомогательных утилит
systemctl enable firewalld --now # Включение frewall
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab # Добавляем строку в fstab для автоматического монтирования шары
systemctl daemon-reload # Перезагрузка systemd
systemctl restart remote-fs.target # Рестарт сервиса remote-fs

```
 - nfss_script.sh
```bash
#/bin/bash 

yum install nfs-utils # Установка вспомогательных утилит
systemctl enable firewalld --now # Включение frewall
firewall-cmd --add-service="nfs3" --add-service="rpc-bind" --add-service="mountd" --permanent # Разрешаем в firewall доступ к сервисам NFS
firewall-cmd --reload # Рестарт firewall
systemctl enable nfs --now # Включение службы nfs
mkdir -p /srv/share/upload # Создание каталога для общего доступа
chown -R nfsnobody:nfsnobody /srv/share # Меняем владельца на nfsnobody
chmod 0777 /srv/share/upload # Меняем права на каталог общего доступа
cat << EOF > /etc/exports # Cоздаём в файле __/etc/exports__ структуру, которая позволит
экспортировать ранее созданную директорию
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
exportfs -r #Экспортируем ранее созданную директорию
```

## Проверка работоспособности:
Предварительно проверяем клиент:
- перезагружаем клиент
- заходим на клиент
- заходим в каталог `/mnt/upload`
- проверяем наличие ранее созданных файлов
Проверяем сервер:
- заходим на сервер в отдельном окне терминала
- перезагружаем сервер
- заходим на сервер
- проверяем наличие файлов в каталоге `/srv/share/upload/`
- проверяем статус сервера NFS `systemctl status nfs`
- проверяем статус firewall `systemctl status firewalld`
- проверяем экспорты `exportfs -s`
- проверяем работу RPC `showmount -a 192.168.50.10`
Проверяем клиент:
- возвращаемся на клиент
- перезагружаем клиент
- заходим на клиент
- проверяем работу RPC `showmount -a 192.168.50.10`
- заходим в каталог `/mnt/upload`
- проверяем статус монтирования `mount | grep mnt`
- проверяем наличие ранее созданных файлов
- создаём тестовый файл `touch final_check`
- проверяем, что файл успешно создан
