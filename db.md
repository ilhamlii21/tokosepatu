# Penjelasan Query MongoDB (`mongodb.js`)

File `mongodb.js` berisi kumpulan sintaks dan operasi yang dijalankan di MongoDB shell. Berikut adalah penjelasan per poin berdasarkan kategori operasinya:

## 1. Membuat & Melihat Collection
- `db.createCollection("nama_collection")`: Digunakan untuk membuat tabel/koleksi baru. Contohnya membuat koleksi `customers`, `products`, dan `orders`.
- `db.getCollectionNames()`: Untuk melihat daftar nama-nama koleksi yang ada pada database saat ini.

## 2. Menambahkan Data (Insert)
- `db.collection.insertOne({ ... })`: Menambahkan satu dokumen (baris data) baru ke dalam koleksi.
- `db.collection.insertMany([ { ... }, { ... } ])`: Menambahkan banyak dokumen sekaligus (dalam bentuk array).

## 3. Mencari Data (Query / Find)
- `db.collection.find()`: Mengambil semua dokumen di dalam koleksi.
- `db.collection.find({ field: "value" })`: Mencari dokumen yang `field`-nya memiliki nilai "value" secara spesifik (mirip `WHERE` pada SQL).
- **Mencari di dalam Array/Embedded Document**: Menggunakan dot notation, misal `"items.product_id": 1`.

## 4. Query Operators
MongoDB memiliki operator yang diawali dengan tanda `$` untuk melakukan query kompleks:

### A. Comparison Operators (Operator Perbandingan)
- `$eq`: *Equal* (sama dengan).
- `$gt`: *Greater than* (lebih besar dari).
- `$in`: Mencari nilai yang ada di dalam sebuah array (misal mencari `category` yang isinya "laptop" atau "handphone").

### B. Logical Operators (Operator Logika)
- `$and`: Menggabungkan beberapa kondisi di mana **semuanya** harus terpenuhi.
- `$not`: Membalikkan hasil logika (yang **tidak** memenuhi kondisi).

### C. Element Operators (Operator Elemen)
- `$exists`: Mengecek apakah sebuah field ada atau tidak (misalnya `$exists: true`).
- `$type`: Mencari dokumen berdasarkan tipe datanya (misal `$type: "string"`).

### D. Evaluation Operators (Operator Evaluasi)
- `$expr`: Memungkinkan penggunaan operator agresi di dalam query `find`, contohnya membandingkan nilai antar dua field di dalam satu dokumen (`$eq: ['$_id', '$name']`).
- `$jsonSchema`: Validasi dokumen yang dicari harus sesuai dengan skema JSON tertentu.
- `$mod`: Operasi modulo/sisa bagi terhadap field numerik.
- `$regex`: Pencarian string berdasarkan regular expression (seperti fungsi `LIKE`).
- `$where`: Menjalankan fungsi JavaScript kustom untuk evaluasi dokumen.

### E. Array Operators (Operator Array)
- `$all`: Memastikan field array mengandung semua elemen yang diminta.
- `$elemMatch`: Mencocokkan kriteria ke elemen-elemen di dalam suatu array.
- `$size`: Mencari field array yang memiliki panjang data sesuai nominal yang dispesifikkan.

## 5. Projection
Digunakan untuk membatasi field apa saja yang akan ditampilkan atau disembunyikan dalam hasil pencarian. Parameter kedua di dalam method `.find()`:
- `{ name: 1, category: 1 }`: Menampilkan (1) hanya field name dan category. (Secara default `_id` akan ikut terbawa).
- `{ tags: 0, price: 0 }`: Menyembunyikan (0) field tags dan price, namun menampilkan yang lainnya.
- Terdapat juga projection array seperti `$` (untuk menampilkan hanya elemen pertama yang matching), atau `$slice` (menampilkan sejumlah elemen tertentu dari array).

## 6. Cursor Methods (Query Modifier)
- `.count()`: Menghitung total dokumen yang ditemukan.
- `.limit(4)`: Membatasi maksimal hanya 4 dokumen yang dikembalikan.
- `.skip(2)`: Melewati 2 dokumen pertama (biasanya dikombinasikan dengan `limit` untuk fitur pagination).
- `.sort({ field: 1 })`: Mengurutkan data. `1` untuk *Ascending* (A-Z), `-1` untuk *Descending* (Z-A).

## 7. Mengubah Data (Update & Replace)
- `db.collection.updateOne(filter, update)`: Mengubah satu dokumen pertama yang memenuhi filter.
- `db.collection.updateMany(filter, update)`: Mengubah seluruh dokumen yang memenuhi kondisi.
- `db.collection.replaceOne(filter, document)`: Mengganti keseluruhan isi dokumen tersebut dengan dokumen yang baru (kecuali `_id`).

### Field Update Operators:
- `$set`: Menambahkan field baru atau mengubah nilai field lama yang sudah ada.
- `$inc`: *Increment*, menambah atau mengurangi (dengan minus) nilai angka.
- `$rename`: Mengubah nama dari suatu field.
- `$unset`: Menghapus sebuah field.
- `$currentDate`: Mengisi nilai field dengan tanggal dan waktu saat perintah dijalankan.

### Array Update Operators:
- `$addToSet`: Memasukkan data ke dalam array hanya jika nilai tersebut belum ada (menghindari duplikasi).
- `$pop`: Menghapus elemen dari sebuah array (nilai `1` untuk elemen terakhir, `-1` untuk elemen pertama).
- `$pull`: Menghapus semua nilai dalam array yang sesuai dengan kriteria tertentu.
- `$pullAll`: Menghapus beberapa nilai spesifik di array sekaligus.
- `$push`: Memasukkan nilai baru ke array di posisi paling belakang. (Bisa dikombinasikan dengan modifier `$each` (banyak data sekaligus), `$position` (index diletakkannya), `$sort`, `$slice`).

## 8. Menghapus Data (Delete)
- `db.collection.deleteOne(filter)`: Menghapus satu dokumen.
- `db.collection.deleteMany(filter)`: Menghapus banyak dokumen.

## 9. Bulk Write
- `db.collection.bulkWrite([ ... ])`: Memungkinkan eksekusi operasi secara berurutan dalam satu perintah sekaligus (bisa berisi *insert*, *update*, *delete*). Sangat efisien karena menghemat pertukaran jaringan ke database server.

## 10. Database Indexing
Indexing sangat penting untuk optimasi agar operasi pencarian data berjalan jauh lebih cepat (tidak perlu table scan keseluruhan):
- `.createIndex({ field: 1 })`: Membuat index pada field tertentu.
- `.dropIndex("index_name")`: Menghapus index.
- `.explain()`: Melihat *execution plan* dari sebuah query (apakah query tersebut memanfaatkan index atau lambat karena menggunakan *COLLSCAN/Collection Scan*).
- **Text Index**: Memfasilitasi pencarian kata penuh (full-text search) melalui operator `$text` dan `$search`. Mendukung bobot/weight fields.
- **Wildcard Index (`$**`)**: Membuat index pada semua sub-field dari dokumen (sangat berguna untuk skema data tak terstruktur).
- **TTL/Expire Index**: Membuat data terhapus secara otomatis berdasarkan durasi yang ditentukan (`expireAfterSeconds`). Sangat berguna untuk data temporary seperti session/otp.
- **Unique & Sparse Index**: Menjamin field harus bersifat unik (`unique: true`) dan tidak wajib ada/sparse.
- **Partial Index**: Membuat index namun hanya yang memenuhi ekspresi kriteria tertentu (misal: stok > 0).

## 11. Database User Management & Auth
- `use admin`: Pindah ke database *admin* yang digunakan untuk otentikasi.
- `db.createUser()`: Membuat user dan password baru lengkap dengan role (hak akses) database yang dimiliki (seperti *readWrite* atau *userAdminAnyDatabase*).
- `db.changeUserPassword()`: Mengganti kata sandi.
- `db.updateUser()`: Mengubah Role hak akses yang dimiliki user.
- `db.dropUser()`: Menghapus User.
- `db.createRole()`: Mendefinisikan Role *custom* dengan priviledge aksi yang spesifik (misal hanya bisa insert data di koleksi tertentu).

## 12. Backup dan Restore Data
Operasi yang dilakukan dari terminal/command prompt biasa (bukan MongoDB shell):
- `mongodump`: Membackup / mengekspor *seluruh data database* dalam format BSON (binary).
- `mongorestore`: Memulihkan data dari format BSON ke dalam MongoDB.
- `mongoexport`: Meng-export data dari sebuah koleksi tertentu ke format JSON atau CSV.
- `mongoimport`: Meng-import data dari format JSON atau CSV ke MongoDB.
