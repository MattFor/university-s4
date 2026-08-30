package efs.task.unittests;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

import static efs.task.unittests.TestConstants.TEST_USER;
import static efs.task.unittests.TestConstants.TEST_USER_DAILY_INTAKE;
import static efs.task.unittests.TestConstants.CALORIES_ON_ACTIVITY_LEVEL;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;

class PlannerTest
{

    private Planner planner;

    @BeforeEach
    void setUp()
    {
        planner = new Planner();
    }

    @ParameterizedTest(name = "{0} -> daily calories demand")
    @EnumSource(ActivityLevel.class)
    void shouldCalculateDailyCaloriesDemand_forAllActivityLevels(ActivityLevel level)
    {
        // Given
        User user = TEST_USER;

        // When
        int calories = planner.calculateDailyCaloriesDemand(user, level);

        // Then
        assertEquals(CALORIES_ON_ACTIVITY_LEVEL.get(level), calories);
    }

    @Test
    void shouldCalculateDailyIntake_forTestUser()
    {
        // Given
        User user = TEST_USER;

        // When
        DailyIntake dailyIntake = planner.calculateDailyIntake(user);

        // Then
        assertAll(
                () -> assertEquals(TEST_USER_DAILY_INTAKE.getCalories(), dailyIntake.getCalories()),
                () -> assertEquals(TEST_USER_DAILY_INTAKE.getProtein(), dailyIntake.getProtein()),
                () -> assertEquals(TEST_USER_DAILY_INTAKE.getFat(), dailyIntake.getFat()),
                () -> assertEquals(TEST_USER_DAILY_INTAKE.getCarbohydrate(), dailyIntake.getCarbohydrate())
        );
    }
}