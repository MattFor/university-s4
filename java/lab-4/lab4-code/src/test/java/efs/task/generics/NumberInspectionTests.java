package efs.task.generics;

import org.junit.jupiter.api.Test;

import static com.github.stefanbirkner.systemlambda.SystemLambda.tapSystemOut;
import static efs.task.generics.NumberInspection.inspectNumberAndReturnTheSameType;
import static org.assertj.core.api.Assertions.assertThat;

class NumberInspectionTests {

    @Test
    void integerInspectionWorks() throws Exception {
        Integer number = 10;
        var printed = tapSystemOut(() -> {
            Integer result = inspectNumberAndReturnTheSameType(number);
            assertThat(result).isEqualTo(number);
        });
        assertThat(printed).contains("Double value of the number of type Integer is: 10.0");
    }

    @Test
    void floatInspectionWorks() throws Exception {
        Float number = 10f;
        var printed = tapSystemOut(() -> {
            Float result = inspectNumberAndReturnTheSameType(number);
            assertThat(result).isEqualTo(number);
        });
        assertThat(printed).contains("Double value of the number of type Float is: 10.0");
    }

    @Test
    void doubleInspectionWorks() throws Exception {
        Double number = 10.0;
        var printed = tapSystemOut(() -> {
            Double result = inspectNumberAndReturnTheSameType(number);
            assertThat(result).isEqualTo(number);
        });
        assertThat(printed).contains("Double value of the number of type Double is: 10.0");
    }
}
