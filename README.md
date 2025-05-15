# `subnet.sh` Kullanım Kılavuzu

Bu betik, verilen bir CIDR IP adresine göre ağ bilgilerini hesaplar ve gösterir.

## Kullanım

1. Betiği `subnet.sh` olarak kaydedin:
    ```bash
    nano subnet.sh
    ```

2. Çalıştırma izni verin:
    ```bash
    chmod +x subnet.sh
    ```

3. Betiği şu şekilde çalıştırın:
    ```bash
    ./subnet.sh 192.168.10.10/24
    ```

## Örnek Çıktı


- Showing : 192.168.10.10/24
- Subnet Mask : 255.255.255.0
- Wildcard Mask : 0.0.0.255
- Host Count : 254
- Network : 192.168.10.0
- Minimum Host : 192.168.10.1
- Maximum Host : 192.168.10.254
- Broadcast : 192.168.10.255



## Açıklamalar

- **Showing**: Girdi olarak verilen IP/CIDR adresi.
- **Subnet Mask**: CIDR'den hesaplanan ağ maskesi.
- **Wildcard Mask**: Alt ağ maskesinin ters çevrilmiş hali.
- **Host Count**: Ağda kullanılabilir toplam host sayısı.
- **Network**: Alt ağın adresi.
- **Minimum Host**: Ağda kullanılabilecek ilk IP adresi.
- **Maximum Host**: Ağda kullanılabilecek son IP adresi.
- **Broadcast**: Yayın adresi (broadcast IP).
