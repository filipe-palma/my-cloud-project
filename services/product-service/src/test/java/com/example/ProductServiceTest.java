package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductServiceTest {
    @Test
    void testGetProduct() {
        ProductService service = new ProductService();
        assertEquals("Product-1", service.getProduct(1));
    }
}