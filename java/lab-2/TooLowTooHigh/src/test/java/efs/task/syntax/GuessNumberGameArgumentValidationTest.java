package efs.task.syntax;

import com.github.stefanbirkner.systemlambda.Statement;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.concurrent.atomic.AtomicReference;

import static com.github.stefanbirkner.systemlambda.SystemLambda.tapSystemOut;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class GuessNumberGameArgumentValidationTest
{

    @ParameterizedTest(name = "argument: \"{0}\"")
    @ValueSource(strings = {"", "abc", "0", "-1", "401"})
    void shouldPrintWrongArgumentMessage(String argument) throws Exception
    {
        //given
        var actualException = new AtomicReference<Exception>();
        var outCaptured = new AtomicReference<String>();

        Statement statement = () ->
        {
            try
            {
                new GuessNumberGame(argument);
            }
            catch (Exception e)
            {
                actualException.set(e);
            }
        };

        //when
        outCaptured.set(tapSystemOut(statement));

        //then
        assertSoftly(softly -> verify(softly, outCaptured.get(), actualException.get()));
    }

    private void verify(SoftAssertions softly, String outCaptured, Exception exception)
    {
        softly.assertThat(outCaptured).as("Program output different than expected").contains("NIEPOPRAWNY ARGUMENT");
        softly.assertThat(exception).as("Wrong type of exception").isInstanceOf(IllegalArgumentException.class);
    }
}

