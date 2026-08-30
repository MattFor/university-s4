package efs.task.syntax;

import java.util.Scanner;
import java.util.Random;

public class GuessNumberGame
{

    private final int secret;
    private final int upperBound;
    private final int triesLimit;

    // Do not modify main method
    public static void main(String[] args)
    {
        try
        {
            GuessNumberGame game = new GuessNumberGame(args.length > 0 ? args[0] : "");
            game.play();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public GuessNumberGame(String argument)
    {
        int parsed;
        try
        {
            parsed = Integer.parseInt(argument);
        }
        catch (Exception e)
        {
            System.out.println(UsefulConstants.WRONG_ARGUMENT);
            throw new IllegalArgumentException(e);
        }

        if (parsed < 1 || parsed > UsefulConstants.MAX_UPPER_BOUND)
        {
            System.out.println(UsefulConstants.WRONG_ARGUMENT);
            throw new IllegalArgumentException("upperBound out of range");
        }

        this.upperBound = parsed;

        // L = floor(log2(upperBound)) + 1
        double log2 = Math.log(upperBound) / Math.log(2);
        this.triesLimit = (int) Math.floor(log2) + 1;

        // Secret in [1, upperBound]
        this.secret = new Random().nextInt(upperBound) + 1;
    }

    public void play()
    {
        System.out.println("<1," + upperBound + ">");
        Scanner scanner = new Scanner(System.in);

        for (int attempt = 1; attempt <= triesLimit; attempt++)
        {
            // Progress bar [***...]
            String progressBar = "[" + "*".repeat(attempt) + ".".repeat(triesLimit - attempt) + "]";
            System.out.println(progressBar);

            System.out.println(UsefulConstants.GIVE_ME);

            String line;
            try
            {
                if (!scanner.hasNextLine())
                {
                    line = "";
                }
                else
                {
                    line = scanner.nextLine();
                }
            }
            catch (Exception e)
            {
                line = "";
            }

            int guess;
            try
            {
                guess = Integer.parseInt(line.trim());
            }
            catch (Exception e)
            {
                System.out.println(UsefulConstants.NOT_A_NUMBER);

                if (attempt == triesLimit)
                {
                    System.out.println(UsefulConstants.UNFORTUNATELY);
                }

                continue;
            }

            if (guess == secret)
            {
                System.out.println(UsefulConstants.YES);
                System.out.println(UsefulConstants.CONGRATULATIONS);
                return;
            }
            else if (guess > secret)
            {
                System.out.println(UsefulConstants.TO_MUCH);
            }
            else
            {
                System.out.println(UsefulConstants.TO_LESS);
            }

            if (attempt == triesLimit)
            {
                System.out.println(UsefulConstants.UNFORTUNATELY);
            }
        }
    }
}