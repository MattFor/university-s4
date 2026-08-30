package efs.task.syntax;

import com.github.stefanbirkner.systemlambda.Statement;

import java.util.concurrent.atomic.AtomicReference;

import static com.github.stefanbirkner.systemlambda.SystemLambda.tapSystemOut;
import static com.github.stefanbirkner.systemlambda.SystemLambda.withTextFromSystemIn;
import static org.junit.jupiter.api.Assertions.fail;

public class SystemLambdaUtils
{
    private SystemLambdaUtils()
    {
    }

    static String runAndCaptureOut(Statement statement, String... inLines)
    {
        var outCaptured = new AtomicReference<String>();

        try
        {
            withTextFromSystemIn(inLines).execute(() -> outCaptured.set(tapSystemOut(statement)));
        }
        catch (Exception e)
        {
            fail(e);
        }

        return outCaptured.get();
    }
}
