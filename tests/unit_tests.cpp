#include <gtest/gtest.h>
#include "../math_operations.h" 


TEST(BasicAddition, PositiveNumbers) {
    EXPECT_EQ(add(5, 5), 10);
}

TEST(BasicAddition, AddingZero) {
    EXPECT_EQ(add(7, 0), 7);
    EXPECT_EQ(add(0, 3), 3);
    EXPECT_EQ(add(0, 0), 0);
}

TEST(BasicAddition, NegativeNumbers) {
    EXPECT_EQ(add(-5, -5), -10);
    EXPECT_EQ(add(-5, 5), 0);
    EXPECT_EQ(add(5, -5), 0);
}

// ----------------------------------------------------
// ПОВЕРТАЄМО: Власна функція main() для запуску тестів
// ----------------------------------------------------
int main(int argc, char **argv) {
    // Ініціалізуємо GoogleTest
    ::testing::InitGoogleTest(&argc, argv);
    // Запускаємо ВСІ тести, які він знайде
    return RUN_ALL_TESTS();
}