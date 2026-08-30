package efs.task.syntax;

import com.github.stefanbirkner.systemlambda.Statement;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.IntStream;

import static efs.task.syntax.SystemLambdaUtils.runAndCaptureOut;
import static java.util.stream.Collectors.toList;
import static org.assertj.core.api.Assertions.assertThat;

class GuessNumberGameProgressBarTest
{

    private static final Pattern PROGRESS_BAR_PATTERN = Pattern.compile("^.*(?<progressBar>\\[\\*+\\.*\\]).*$");

    @ParameterizedTest(name = "upperBound: {0}")
    @ValueSource(ints = {1, 2, 4, 8, 10, 20, 100, 200})
    void shouldPrintWrongArgumentMessage(int upperBound)
    {
        //given

        int triesLimit = calculateTriesLimit(upperBound);
        var inLines = inLines(triesLimit);
        var expectedProgressBars = expectedProgressBars(triesLimit);

        Statement statement = () ->
        {
            var game = new GuessNumberGame(String.valueOf(upperBound));
            game.play();
        };

        //when
        var outCaptured = runAndCaptureOut(statement, inLines);

        //then
        assertThat(actualProgressBar(outCaptured)).as("Progress bar different than expected").containsExactlyElementsOf(expectedProgressBars);
    }

    private int calculateTriesLimit(int upperBound)
    {
        double log2UpperBound = Math.log(upperBound) / Math.log(2);
        return (int) Math.floor(log2UpperBound) + 1;
    }

    private List<String> expectedProgressBars(int triesLimit)
    {
        return IntStream.rangeClosed(1, triesLimit)
                .mapToObj(i -> "[" + "*".repeat(i) + ".".repeat(triesLimit - i) + "]")
                .collect(toList());
    }

    private List<String> actualProgressBar(String outCaptured)
    {
        return outCaptured.lines()
                .map(PROGRESS_BAR_PATTERN::matcher)
                .peek(Matcher::find)
                .filter(Matcher::matches)
                .map(matcher -> matcher.group("progressBar"))
                .collect(toList());
    }

    private String[] inLines(int triesLimit)
    {
        String[] inLines = new String[triesLimit];
        Arrays.fill(inLines, "abc");
        return inLines;
    }
}

