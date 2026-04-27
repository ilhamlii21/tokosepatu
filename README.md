# Smart Product Comparison - API & Database Documentation

Aplikasi ini tidak memiliki *custom backend API* (seperti Express, Laravel, atau Spring Boot). Sebaliknya, aplikasi ini berinteraksi langsung dengan **Supabase** menggunakan pola **BaaS (Backend-as-a-Service)** melalui _package_ `supabase_flutter`.

Berikut adalah dokumentasi skema database dan bagaimana aplikasi berinteraksi dengan API Supabase.

## Konfigurasi Supabase
Kredensial API disimpan dalam kelas `SupabaseConfig` (`lib/supabase.dart`):
- **URL**: `https://lxxvngrhuwjtktssrlws.supabase.co`
- **Anon Key**: (Disembunyikan untuk keamanan, namun merupakan JWT Token untuk akses API publik / anonim)

## Database Schema (NoSQL Pendekatan Document)

Tabel utama yang digunakan adalah `products`. Meskipun Supabase berbasis PostgreSQL (relational), kita memanfaatkan kolom bertipe **JSONB** (`details`) untuk meniru perilaku *document-oriented NoSQL* (seperti MongoDB).

### Struktur Tabel `products`

| Kolom      | Tipe Data | Keterangan                                                                 |
|------------|-----------|----------------------------------------------------------------------------|
| `id`       | integer   | Primary Key, Auto-increment.                                               |
| `name`     | varchar   | Nama dari produk (contoh: "Macbook Air M2", "Nike Air Max").               |
| `category` | varchar   | Kategori dari produk (contoh: "Laptop", "Sepatu").                         |
| `details`  | jsonb     | **[NoSQL Core]** Pasangan _Key-Value_ dinamis yang berisi atribut spesifik.|

### Contoh Struktur Data `details` (JSON)

Karena menggunakan tipe `jsonb`, produk dengan kategori berbeda bisa memiliki *keys* atau atribut yang berbeda di dalam tabel yang sama.

**Contoh 1: Produk Laptop**
```json
{
  "processor": "Apple M2",
  "ram": "8 GB",
  "storage": "256 GB SSD",
  "garansi": "1 Tahun"
}
```

**Contoh 2: Produk Sepatu**
```json
{
  "bahan": "Kulit Sintetis",
  "warna": "Hitam",
  "ukuran": "42",
  "outsole": "Rubber"
}
```

---

## Endpoint Operasi (Melalui Supabase Client API)

Operasi CRUD dilakukan di *client-side* menggunakan *method chaining* dari *library* `supabase_flutter`.

### 1. Fetch / Read All Products
Digunakan di `ComparisonScreen` untuk mengambil seluruh daftar produk.

```dart
final response = await supabase.from('products').select();
// Mengembalikan tipe data List<dynamic> berupa array of objects
```

### 2. Insert / Create New Product
Digunakan di `ProductFormScreen` saat menambahkan produk baru.

```dart
final newData = {
  'name': 'Asus ROG',
  'category': 'Laptop',
  'details': { // Atribut dinamis dimasukkan sebagai Map/JSON
    'VGA': 'RTX 4060',
    'Refresh Rate': '144Hz'
  }
};

await supabase.from('products').insert(newData);
```

### 3. Update Existing Product
Digunakan di `ProductFormScreen` saat menyimpan perubahan dari produk yang diedit.

```dart
final updatedData = {
  'name': 'Asus ROG Strix', // Nama diubah
  'details': {
    'VGA': 'RTX 4060',
    'Refresh Rate': '165Hz' // Atribut diubah
  }
};

// Menggunakan filter .eq('id', value)
await supabase.from('products').update(updatedData).eq('id', product.id);
```

---

## Kemampuan *Schema-less*
Keuntungan utama dari API ini adalah fleksibilitasnya. Jika tim bisnis tiba-tiba memutuskan untuk menambahkan atribut `"berat": "2 kg"` ke produk laptop, developer **TIDAK PERLU**:
1. Menulis script `ALTER TABLE products ADD COLUMN berat VARCHAR;` di database.
2. Mengubah definisi `class Product` di Flutter (karena sudah ditangani dengan tipe data `Map<String, dynamic>`).

Aplikasi akan otomatis membaca atribut baru tersebut dari respon JSON Supabase dan merendernya secara instan di UI Tabel Perbandingan.
