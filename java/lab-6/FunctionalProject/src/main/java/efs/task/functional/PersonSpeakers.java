package efs.task.functional;

class PersonSpeakers
{

    private final String HELLO = "Hello. I'm ";
    private final String CZESC = "Czesc. Jestem ";
    private final String HALLO = "Hallo, ich heiBe ";


    Speaker createGreetSpeaker()
    {
        // Implementacja interfejsu Speaker za pomocą wyrażenia lambda. Implementacja w tej postaci możliwa jest
        // dzięki temu, że Speaker jest interfejsem funkcyjnym - posiada tylko jedną metodę abstrakcyjną.
        return p -> HELLO + p.getName();
    }

    Speaker createShoutingSpeaker()
    {
        return person -> (HELLO + person.getName()).toUpperCase();
    }

    Speaker createGreetLocalSpeaker()
    {
        return person ->
        {
            if (person.getCountryOfLiving() == Country.PL)
            {
                return CZESC + person.getName();
            }
            else if (person.getCountryOfLiving() == Country.DE)
            {
                return HALLO + person.getName();
            }

            return HELLO + person.getName();
        };
    }
}
