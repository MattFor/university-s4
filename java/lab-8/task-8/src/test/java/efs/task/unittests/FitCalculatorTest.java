package efs.task.unittests;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.junit.jupiter.params.provider.CsvFileSource;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertArrayEquals;

import static efs.task.unittests.TestConstants.TEST_USERS_LIST;
import static efs.task.unittests.TestConstants.TEST_USERS_BMI_SCORE;

class FitCalculatorTest
{

    @Test
    void shouldReturnTrue_whenDietRecommended()
    {
        // Given
        double weight = 89.2;
        double height = 1.72;

        // When
        boolean recommended = FitCalculator.isBMICorrect(weight, height);

        // Then
        assertTrue(recommended);
    }

    @Test
    void shouldReturnFalse_whenDietNotRecommended()
    {
        // Given
        double weight = 69.5;
        double height = 1.72;

        // When
        boolean recommended = FitCalculator.isBMICorrect(weight, height);

        // Then
        assertFalse(recommended);
    }

    @Test
    void shouldThrowIllegalArgumentException_whenHeightIsZero()
    {
        // Given
        double weight = 69.5;
        double height = 0.0;

        // When / Then
        assertThrows(IllegalArgumentException.class, () -> FitCalculator.isBMICorrect(weight, height));
    }

    @ParameterizedTest(name = "weight={0}, height=1.72 -> BMI correct")
    @ValueSource(doubles = {75.0, 80.0, 85.0})
    void shouldReturnTrue_forDifferentWeights_whenHeightIsFixed(double weight)
    {
        // Given
        double height = 1.72;

        // When
        boolean recommended = FitCalculator.isBMICorrect(weight, height);

        // Then
        assertTrue(recommended);
    }

    @ParameterizedTest(name = "weight={0}, height={1} -> BMI incorrect")
    @CsvFileSource(resources = "/data.csv", numLinesToSkip = 1)
    void shouldReturnFalse_forDifferentWeightAndHeightPairs(double weight, double height)
    {
        // Given / When
        boolean recommended = FitCalculator.isBMICorrect(weight, height);

        // Then
        assertFalse(recommended);
    }

    @ParameterizedTest(name = "weight={0}, height={1} -> BMI incorrect from csv")
    @CsvFileSource(resources = "/data.csv", numLinesToSkip = 1)
    void shouldReturnFalse_forPairsFromCsvFile(double weight, double height)
    {
        // Given / When
        boolean recommended = FitCalculator.isBMICorrect(weight, height);

        // Then
        assertFalse(recommended);
    }

    @Test
    void shouldReturnUserWithTheWorstBMI_forTestUsersList()
    {
        // Given
        List<User> users = TEST_USERS_LIST;

        // When
        User worstUser = FitCalculator.findUserWithTheWorstBMI(users);

        // Then
        assertNotNull(worstUser);
        assertSame(TEST_USERS_LIST.get(2), worstUser);
        assertEquals(97.3, worstUser.getWeight(), 0.0);
        assertEquals(1.79, worstUser.getHeight(), 0.0);
    }

    @Test
    void shouldReturnNull_whenUsersListIsEmpty()
    {
        // Given
        List<User> users = List.of();

        // When
        User worstUser = FitCalculator.findUserWithTheWorstBMI(users);

        // Then
        assertNull(worstUser);
    }

    @Test
    void shouldReturnBMIValues_forTestUsersList()
    {
        // Given
        List<User> users = TEST_USERS_LIST;

        // When
        double[] bmiScores = FitCalculator.calculateBMIScore(users);

        // Then
        assertArrayEquals(TEST_USERS_BMI_SCORE, bmiScores, 0.01);
    }
}