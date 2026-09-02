const Database = require("better-sqlite3");
const path = require("path");
const axios = require("axios");

const dbPath = path.join(__dirname, process.env.DB_PATH || "products.db");
const db = new Database(dbPath);

// Enable foreign keys
db.pragma("foreign_keys = ON");

/**
 * Initialize database schema
 * Creates products table if it doesn't exist
 */
function initializeDatabase() {
  console.log("🔧 Initializing database schema...");

  try {
    // Create products table
    db.exec(`
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create indexes for performance
    db.exec(`
      CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
      CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
      CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
    `);

    console.log("✅ Database schema initialized successfully");
  } catch (error) {
    console.error("❌ Error initializing database schema:", error.message);
    throw error;
  }
}

/**
 * Check if database is already seeded
 * Returns true if products table has data
 */
function isDatabaseSeeded() {
  try {
    const result = db.prepare("SELECT COUNT(*) as count FROM products").get();
    return result.count > 0;
  } catch (error) {
    return false;
  }
}

/**
 * Seed database from external API
 * Fetches all products and inserts into local SQLite database
 */
async function seedDatabase() {
  if (isDatabaseSeeded()) {
    const count = db
      .prepare("SELECT COUNT(*) as count FROM products")
      .get().count;
    console.log(
      `📦 Database already seeded with ${count} products. Skipping...`,
    );
    return;
  }

  console.log("🌱 Starting database seeding from external API...");

  try {
    // Fetch products from external API
    console.log(`📡 Fetching products from: ${process.env.EXTERNAL_API_URL}`);
    const response = await axios.get(process.env.EXTERNAL_API_URL, {
      timeout: 30000, // 30 second timeout
    });

    const products = response.data;
    console.log(`📥 Received ${products.length} products from external API`);

    if (!Array.isArray(products) || products.length === 0) {
      console.warn("⚠️ No products received from external API");
      return;
    }

    // Prepare insert statement
    const insertStmt = db.prepare(`
      INSERT INTO products (id, name, price, category)
      VALUES (?, ?, ?, ?)
    `);

    // Begin transaction for better performance
    const insertMany = db.transaction((products) => {
      let successCount = 0;
      let errorCount = 0;

      for (const product of products) {
        try {
          // Validate required fields
          if (
            !product.id ||
            !product.name ||
            product.price === undefined ||
            !product.category
          ) {
            errorCount++;
            continue;
          }

          insertStmt.run(
            product.id,
            product.name,
            parseFloat(product.price),
            product.category,
          );
          successCount++;
        } catch (error) {
          errorCount++;
          console.warn(`⚠️ Skipped product ID ${product.id}:`, error.message);
        }
      }

      return { successCount, errorCount };
    });

    const { successCount, errorCount } = insertMany(products);
    console.log(`✅ Seeding complete: ${successCount} products inserted`);

    if (errorCount > 0) {
      console.warn(`⚠️ ${errorCount} products skipped due to errors`);
    }
  } catch (error) {
    console.warn(
      "⚠️  WARNING: Could not fetch from external API:",
      error.message,
    );
    if (error.response) {
      console.warn("   API Response Status:", error.response.status);
    }
    console.log("🔄 Attempting to insert demo products instead...");
    insertDemoData();
  }
}

/**
 * Insert demo data if database is empty
 * Fallback data for development/testing
 */
function insertDemoData() {
  try {
    // Check if already has data
    const existing = db
      .prepare("SELECT COUNT(*) as count FROM products")
      .get().count;
    if (existing > 0) {
      console.log(
        `✅ Database already has ${existing} products. Skipping demo data.`,
      );
      return;
    }

    console.log("📝 Inserting demo product data...");

    const demoProducts = [
      {
        id: 1,
        name: "Wireless Headphones",
        price: 49.99,
        category: "Electronics",
      },
      { id: 2, name: "USB-C Cable", price: 12.99, category: "Electronics" },
      { id: 3, name: "Phone Case", price: 15.99, category: "Electronics" },
      { id: 4, name: "Screen Protector", price: 8.99, category: "Electronics" },
      {
        id: 5,
        name: "Portable Charger",
        price: 29.99,
        category: "Electronics",
      },
      { id: 6, name: "Cotton T-Shirt", price: 19.99, category: "Fashion" },
      { id: 7, name: "Blue Jeans", price: 49.99, category: "Fashion" },
      { id: 8, name: "Winter Jacket", price: 89.99, category: "Fashion" },
      { id: 9, name: "Running Shoes", price: 79.99, category: "Fashion" },
      { id: 10, name: "Baseball Cap", price: 24.99, category: "Fashion" },
      { id: 11, name: "LED Desk Lamp", price: 34.99, category: "Home" },
      { id: 12, name: "Coffee Maker", price: 59.99, category: "Home" },
      { id: 13, name: "Throw Pillow", price: 22.99, category: "Home" },
      { id: 14, name: "Bath Towel Set", price: 39.99, category: "Home" },
      { id: 15, name: "Wall Clock", price: 29.99, category: "Home" },
      { id: 16, name: "Yoga Mat", price: 25.99, category: "Sports" },
      { id: 17, name: "Dumbbells Set", price: 44.99, category: "Sports" },
      { id: 18, name: "Basketball", price: 34.99, category: "Sports" },
      { id: 19, name: "Tennis Racket", price: 89.99, category: "Sports" },
      { id: 20, name: "Water Bottle", price: 19.99, category: "Sports" },
    ];

    const insertStmt = db.prepare(`
      INSERT INTO products (id, name, price, category)
      VALUES (?, ?, ?, ?)
    `);

    const insertMany = db.transaction((products) => {
      let inserted = 0;
      for (const product of products) {
        try {
          insertStmt.run(
            product.id,
            product.name,
            product.price,
            product.category,
          );
          inserted++;
        } catch (e) {
          // Skip duplicates or errors
        }
      }
      return inserted;
    });

    const count = insertMany(demoProducts);
    console.log(`✅ Inserted ${count} demo products successfully`);
  } catch (error) {
    console.warn("⚠️  Could not insert demo data:", error.message);
  }
}

/**
 * Get database statistics
 */
function getDbStats() {
  try {
    const stats = {
      totalProducts: db.prepare("SELECT COUNT(*) as count FROM products").get()
        .count,
      categories: db
        .prepare("SELECT COUNT(DISTINCT category) as count FROM products")
        .get().count,
      priceRange: db
        .prepare(
          `
        SELECT MIN(price) as min, MAX(price) as max 
        FROM products
      `,
        )
        .get(),
    };
    return stats;
  } catch (error) {
    console.error("Error getting database stats:", error.message);
    return null;
  }
}

/**
 * Close database connection
 */
function closeDatabase() {
  if (db) {
    db.close();
    console.log("🔌 Database connection closed");
  }
}

/**
 * Execute database initialization and seeding on module load
 */
async function start() {
  try {
    initializeDatabase();
    await seedDatabase();

    // Display statistics
    const stats = getDbStats();
    if (stats) {
      console.log("\n📊 Database Statistics:");
      console.log(`   Total Products: ${stats.totalProducts}`);
      console.log(`   Total Categories: ${stats.categories}`);
      if (stats.priceRange.min !== null) {
        console.log(
          `   Price Range: $${stats.priceRange.min} - $${stats.priceRange.max}`,
        );
      }
    }
  } catch (error) {
    console.error("❌ Critical database initialization error:", error);
    process.exit(1);
  }
}

// Export functions
module.exports = {
  db,
  start,
  closeDatabase,
  isDatabaseSeeded,
  getDbStats,
};
