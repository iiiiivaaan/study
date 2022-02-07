# Задание:
- Добавить в Vagrantfile еще дисков;
- Сломать/починить raid;
- Собрать R0/R5/R10 на выбор;
- Прописать собранный рейд в конф, чтобы рейд собирался при загрузке;
- Создать GPT раздел и 5 партиций.

В качестве проверки принимаются - измененный Vagrantfile,  скрипт для создания рейда, конф для автосборки рейда при загрузке.

# Добавил диски в в Vagrntfile

```sh
       :disks => {
                :sata1 => {
                        :dfile => './sata1.vdi',
                        :size => 250, # Megabytes
                        :port => 1
                },
                :sata2 => {
                        :dfile => './sata2.vdi',
                        :size => 250, # Megabytes
                        :port => 2
                },
                :sata3 => {
                        :dfile => './sata3.vdi',
                        :size => 250, # Megabytes
                        :port => 3
                },
                :sata4 => {
                        :dfile => './sata4.vdi',
                        :size => 250, # Megabytes
                        :port => 4
                },
                :sata5 => {
                        :dfile => './sata5.vdi',
                        :size => 250, # Megabytes
                        :port => 5
                }

```

# Собрал рейд

Проверил какие диски есть 
```sh
fdisk -l
```

Занулил суперблоки
```sh
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
```

Собрал рейд
```
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
```

Проверил состояние рейда
```sh
cat /proc/mdstat
mdadm -D /dev/md0
```

Создал файл mdadm.conf
```sh
mdadm --detail --scan --verbose
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
```

# Сломал и починил рейд

Сломал диск 
```sh
mdadm /dev/md0 --fail /dev/sde
```

Посмотрел статус рейда 
```sh
mdadm -D /dev/md0
```

Удалил диск из рейда
```sh
mdadm /dev/md0 --remove /dev/sde
```

Добавил "новый" диск в рейд
```sh
mdadm /dev/md0 --add /dev/sde
```

