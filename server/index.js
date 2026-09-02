require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { db, start: initializeDb, closeDatabase, getDbStats } = require("./db");

const app = express();
const PORT = process.env.PORT || 5000;

// ==================== MIDDLEWARE ====================
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    credentials: true,
  }),
);
app.use(express.json());

// ==================== UTILITY FUNCTIONS ====================

/**
 * Validate and sanitize search query
 */
function sanitizeSearch(search) {
  if (!search || typeof search !== "string") return "";
  return search.trim().substring(0, 100);
}

/**
 * Validate sort parameter
 */
function validateSort(sort) {
  return sort === "desc" ? "DESC" : "ASC";
}

/**
 * Validate and parse pagination parameters
 */
function validatePagination(page, limit) {
  let p = parseInt(page) || 1;
  let l = parseInt(limit) || 20;

  p = Math.max(1, p); // Minimum page 1
  l = Math.min(Math.max(1, l), 100); // Limit between 1-100

  return { page: p, limit: l };
}

/**
 * Build dynamic WHERE clause based on filters
 */
function buildWhereClause(search, category) {
  const conditions = [];
  const params = {};

  if (search && search.trim()) {
    conditions.push("name LIKE :search");
    params.search = `%${sanitizeSearch(search)}%`;
  }

  if (category && category.trim() && category !== "all" && category !== "") {
    conditions.push("category = :category");
    params.category = category.trim();
  }

  const whereClause =
    conditions.length > 0 ? "WHERE " + conditions.join(" AND ") : "";
  return { whereClause, params };
}

// ==================== API ROUTES ====================

/**
 * GET /api/health
 * Health check endpoint
 */
app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    message: "Server is running",
    timestamp: new Date().toISOString(),
  });
});

/**
 * GET /api/stats
 * Database statistics
 */
app.get("/api/stats", (req, res) => {
  try {
    const stats = getDbStats();
    res.json(stats);
  } catch (error) {
    console.error("Error fetching stats:", error);
    res.status(500).json({ error: "Failed to fetch database statistics" });
  }
});

/**
 * GET /api/categories
 * Returns list of all unique categories
 *
 * Response:
 * {
 *   "categories": ["Electronics", "Fashion", "Home", ...]
 * }
 */
app.get("/api/categories", (req, res) => {
  try {
    console.log("📍 GET /api/categories requested");

    const stmt = db.prepare(`
      SELECT DISTINCT category FROM products 
      ORDER BY category ASC
    `);

    const categories = stmt.all().map((row) => row.category);

    console.log(`✅ Returning ${categories.length} categories`);
    res.json({
      categories: categories,
      count: categories.length,
    });
  } catch (error) {
    console.error("❌ Error fetching categories:", error.message);
    res.status(500).json({
      error: "Failed to fetch categories",
      message: error.message,
    });
  }
});

/**
 * GET /api/products
 * Returns paginated and filtered products
 *
 * Query Parameters:
 * - search (optional): Search term for product name
 * - category (optional): Filter by category
 * - sort (optional): 'asc' or 'desc' for price sorting
 * - page (optional): Page number, default 1
 * - limit (optional): Items per page, default 20, max 100
 *
 * Response:
 * {
 *   "products": [...],
 *   "totalCount": 500,
 *   "currentPage": 1,
 *   "totalPages": 25,
 *   "limit": 20
 * }
 */
app.get("/api/products", (req, res) => {
  try {
    const { search, category, sort, page, limit } = req.query;

    console.log("📍 GET /api/products requested");
    console.log(
      `   Filters: search="${search}", category="${category}", sort="${sort}"`,
    );
    console.log(`   Pagination: page=${page}, limit=${limit}`);

    // Validate pagination
    const { page: validPage, limit: validLimit } = validatePagination(
      page,
      limit,
    );
    const offset = (validPage - 1) * validLimit;

    // Validate sort
    const sortOrder = validateSort(sort);

    // Build WHERE clause
    const { whereClause, params } = buildWhereClause(search, category);

    // Query 1: Get total count
    let countQuery = `SELECT COUNT(*) as count FROM products ${whereClause}`;
    const countResult = db.prepare(countQuery).get(params);
    const totalCount = countResult.count;
    const totalPages = Math.ceil(totalCount / validLimit);

    // Query 2: Get paginated products
    let productsQuery = `
      SELECT id, name, price, category 
      FROM products 
      ${whereClause}
      ORDER BY price ${sortOrder}
      LIMIT :limit OFFSET :offset
    `;

    params.limit = validLimit;
    params.offset = offset;

    const stmt = db.prepare(productsQuery);
    const products = stmt.all(params);

    console.log(
      `✅ Returning ${products.length} products (Page ${validPage}/${totalPages})`,
    );

    res.json({
      products: products,
      totalCount: totalCount,
      currentPage: validPage,
      totalPages: totalPages,
      limit: validLimit,
      hasNextPage: validPage < totalPages,
      hasPrevPage: validPage > 1,
    });
  } catch (error) {
    console.error("❌ Error fetching products:", error.message);
    res.status(500).json({
      error: "Failed to fetch products",
      message: error.message,
    });
  }
});

/**
 * GET /api/products/:id
 * Returns a single product by ID
 *
 * Response:
 * {
 *   "id": 1,
 *   "name": "Product Name",
 *   "price": 29.99,
 *   "category": "Electronics"
 * }
 *
 * Returns 404 if product not found
 */
app.get("/api/products/:id", (req, res) => {
  try {
    const { id } = req.params;

    console.log(`📍 GET /api/products/${id} requested`);

    // Validate ID is a number
    if (isNaN(id)) {
      return res.status(400).json({
        error: "Invalid product ID",
        message: "Product ID must be a number",
      });
    }

    const stmt = db.prepare(`
      SELECT id, name, price, category 
      FROM products 
      WHERE id = ?
    `);

    const product = stmt.get(parseInt(id));

    if (!product) {
      console.log(`⚠️ Product ID ${id} not found`);
      return res.status(404).json({
        error: "Product not found",
        message: `No product with ID ${id}`,
      });
    }

    console.log(`✅ Returning product: ${product.name}`);
    res.json(product);
  } catch (error) {
    console.error("❌ Error fetching product:", error.message);
    res.status(500).json({
      error: "Failed to fetch product",
      message: error.message,
    });
  }
});

// ==================== ERROR HANDLING ====================

/**
 * 404 - Not Found
 */
app.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    message: `Endpoint ${req.method} ${req.path} does not exist`,
    availableEndpoints: [
      "GET /api/health",
      "GET /api/stats",
      "GET /api/categories",
      "GET /api/products?search=&category=&sort=asc&page=1&limit=20",
      "GET /api/products/:id",
    ],
  });
});

/**
 * Global error handler
 */
app.use((error, req, res, next) => {
  console.error("❌ Unhandled error:", error);
  res.status(error.status || 500).json({
    error: error.message || "Internal Server Error",
    status: error.status || 500,
  });
});

// ==================== SERVER STARTUP ====================

/**
 * Start server with database initialization
 */
async function startServer() {
  try {
    // Initialize database
    await initializeDb();

    // Start Express server
    const server = app.listen(PORT, () => {
      console.log("\n🚀 Server started successfully!");
      console.log(`📌 Server running at: http://localhost:${PORT}`);
      console.log(`\n📚 Available Endpoints:`);
      console.log(`   GET  http://localhost:${PORT}/api/health`);
      console.log(`   GET  http://localhost:${PORT}/api/stats`);
      console.log(`   GET  http://localhost:${PORT}/api/categories`);
      console.log(
        `   GET  http://localhost:${PORT}/api/products?search=&category=&sort=asc&page=1&limit=20`,
      );
      console.log(`   GET  http://localhost:${PORT}/api/products/:id`);
      console.log("\n💡 Tip: Use Postman or curl to test endpoints\n");
    });

    // Graceful shutdown
    process.on("SIGINT", () => {
      console.log("\n🛑 Shutting down gracefully...");
      server.close(() => {
        closeDatabase();
        console.log("👋 Server stopped");
        process.exit(0);
      });
    });
  } catch (error) {
    console.error("❌ Failed to start server:", error);
    process.exit(1);
  }
}

// Start the server
startServer();

module.exports = app;
