# NFS стенд 
1. Механика работы стенда.
- 1.1 Vagrant-файл поднимает две виртуальные машины: **server**, **client**
- 1.2 В процессе загрузки машин выполняются скрипты, общие для всех ВМ
```sh
        yum install nfs-utils -y
        yum install firewalld -y
        systemctl start firewalld.service
        systemctl enable firewalld.service; exit 0
```
- 1.3 После загрузки, машины выполняют скрипты по настройке сервера и клиента для NFS.
- 1.4 При удачном завершении скриптов создаётся файл на стороне клиента ***CheckPermissionIsOK***.
- 1.5 Для тестирования выполняем вход на **server** и в папке **Upload** проверяем наличие файла ***CheckPermissionIsOK***.
        ```
        -rw-r--r--. 1 vagrant vagrant   0 May 25 18:45 CheckPermissionIsOK
        ```
2.  Процесс настройки машин выполняется по сценарию скриптов отдельно для сервера и клиента.
- 2.1 Срипт на стороне сервера выполняет следующие шаги:
            2.2 Создаёт общую директорию, устанавливает права доступа:
```sh
        mkdir /home/vagrant/Upload
        chmod -R 755 /home/vagrant/Upload
        chown vagrant:vagrant /home/vagrant/Upload
```
- 2.3 Экспортирует файловую систему для монтирования на клиенте:
```sh
        cat > /etc/exports <<EOF
        /home/vagrant/Upload 192.168.11.102(async,rw,no_subtree_check,root_squash,anonuid=1000,anongid=1000)
EOF 
```
```sh
        exportfs -arv
```
- 2.4 Активирует и запускает службы NFS
```sh
        systemctl enable rpcbind
        systemctl enable nfs-server
        systemctl enable nfs-lock
        systemctl enable nfs-idmap
        systemctl start rpcbind
        systemctl start nfs-server
        systemctl start nfs-lock
        systemctl start nfs-idmap
        systemctl restart nfs-server
```
- 2.5 Разрешаем порты в файерволе для работы общего доступа
```sh
        firewall-cmd --permanent --add-port=111/tcp
        firewall-cmd --permanent --add-port=54302/tcp
        firewall-cmd --permanent --add-port=20048/tcp
        firewall-cmd --permanent --add-port=2049/tcp
        firewall-cmd --permanent --add-port=46666/tcp
        firewall-cmd --permanent --add-port=42955/tcp
        firewall-cmd --permanent --add-port=875/tcp
        firewall-cmd --permanent --zone=public --add-service=nfs
        firewall-cmd --permanent --zone=public --add-service=mountd
        firewall-cmd --permanent --zone=public --add-service=rpc-bind
        firewall-cmd --reload
```
# Сервер готов к работе. #
- 2.6 Настройка клиента аналогичная серверной (п.2.5, п.2.4)
- 2.7 Создаёт директорию для монтирования общей папки и прописывает в автозагрузку монтирование
```sh
        mkdir -p /mnt/nfs/Upload
        mount -t nfs -o nfsvers=3 192.168.11.101:/home/vagrant/Upload/ /mnt/nfs/Upload/
        cat >> /etc/fstab <<EOF
        192.168.11.101:/home/vagrant/Upload/ /mnt/nfs/Upload/ nfs defaults 0 0
EOF
```
- 2.8 Проверяем доступность общей папки и создаём в ней файл:
```sh
        touch /mnt/nfs/Upload/CheckPermissionIsOK
```
- 2.9 Работа скрипта завершена без ошибок, на стороне клиента в общей папке создан файл, который видно на стороне сервера.
