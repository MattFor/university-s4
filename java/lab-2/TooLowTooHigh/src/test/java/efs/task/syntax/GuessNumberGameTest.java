package efs.task.syntax;

import com.github.stefanbirkner.systemlambda.Statement;
import org.assertj.core.api.SoftAssertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Timeout;

import static efs.task.syntax.SystemLambdaUtils.runAndCaptureOut;
import static java.lang.System.lineSeparator;
import static org.assertj.core.api.SoftAssertions.assertSoftly;

class GuessNumberGameTest
{

    @Test
    @Timeout(10)
    void shouldPrintNotNumberMessage()
    {
        //given
        Statement statement = () ->
        {
            var game = new GuessNumberGame("1");
            game.play();
        };

        //when
        var outCaptured = runAndCaptureOut(statement, "abc");

        //then
        assertSoftly(softly -> verifyOutput(softly, outCaptured, "NIE LICZBA", "NIESTETY"));
    }

    @Test
    void shouldPrintYesMessage()
    {
        //given
        Statement statement = () ->
        {
            var game = new GuessNumberGame("1");
            game.play();
        };

        //when
        var outCaptured = runAndCaptureOut(statement, "1");

        //then
        assertSoftly(softly -> verifyOutput(softly, outCaptured, "TAK", "GRATULACJE"));
    }

    @Test
    void shouldPrintToMuchMessage()
    {
        //given
        Statement statement = () ->
        {
            var game = new GuessNumberGame("1");
            game.play();
        };

        //when
        var outCaptured = runAndCaptureOut(statement, "2");

        //then
        assertSoftly(softly -> verifyOutput(softly, outCaptured, "ZBYT WIELE", "NIESTETY"));
    }

    @Test
    void shouldPrintToLessMessage()
    {
        //given
        Statement statement = () ->
        {
            var game = new GuessNumberGame("1");
            game.play();
        };

        //when
        var outCaptured = runAndCaptureOut(statement, "0");

        //then
        assertSoftly(softly -> verifyOutput(softly, outCaptured, "NIE WYSTARCZY", "NIESTETY"));
    }

    private void verifyOutput(SoftAssertions softly, String outCaptured, String comparisonResult, String result)
    {
        var outLines = outCaptured.split(lineSeparator());

        softly.assertThat(outLines[0]).as("Welcome message different than expected").contains("<1,1>");
        softly.assertThat(outLines[1]).as("Progress bar different than expected").contains("[*]");
        softly.assertThat(outLines[2]).as("Prompt message different than expected").contains("PODAJ");
        softly.assertThat(outLines[3]).as("Comparison result different than expected").contains(comparisonResult);
        softly.assertThat(outLines[4]).as("Result different than expected").contains(result);
    }
}