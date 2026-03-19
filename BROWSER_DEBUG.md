# Browser Console Test - API URL Kontrolü

## Lütfen şunları yapın:

1. **Siteyi açın**: http://124.243.177.173:8080
2. **F12** tuşuna basarak Developer Tools'u açın
3. **Console** sekmesine geçin
4. Aşağıdaki kodu Console'a yapıştırıp **Enter**'a basın:

```javascript
console.log('=== SpineAI Debug Info ===');
console.log('1. Local Storage Token:', localStorage.getItem('accessToken') ? 'VAR' : 'YOK');
console.log('2. User:', localStorage.getItem('user'));

// Test API URL
fetch('http://124.243.177.173:8080/api/auth/me', {
    headers: {
        'Authorization': 'Bearer ' + localStorage.getItem('accessToken')
    }
})
.then(res => res.json())
.then(data => console.log('3. API Test Sonucu:', data))
.catch(err => console.error('3. API Test HATASI:', err));

// Window içindeki global değişkenleri kontrol et
console.log('4. Import Meta:', typeof import !== 'undefined');
console.log('======================');
```

5. **Dashboard** sayfasına gidin
6. Bir **resim seçin**
7. **START ANALYSIS** butonuna tıklayın
8. **Network** sekmesine geçin
9. Hangi isteklerin gönderildiğini görün
10. Eğer hata varsa, hata mesajını buraya yapıştırın

## Alternatif: Resim ekran görüntüsü

Eğer yapamıyorsanız, **F12 > Console** ve **F12 > Network** sekmelerinin ekran görüntüsünü alıp bana gösterin.

## Kontrol edilecekler:
- ✅ Token var mı?
- ✅ API isteği hangi URL'e gidiyor?
- ✅ Hangi hata mesajı alınıyor?
