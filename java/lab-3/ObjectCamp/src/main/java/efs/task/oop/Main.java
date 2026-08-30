package efs.task.oop;

public class Main
{
    public static void main(String[] args)
    {
        Villager kashya = new Villager("Kashya", 30);
        ExtraordinaryVillager akara = new ExtraordinaryVillager("Akara", 40, ExtraordinaryVillager.Skill.SHELTER);
        Villager gheed = new Villager("Gheed", 50);
        ExtraordinaryVillager deckardCain = new ExtraordinaryVillager("Deckard Cain", 85, ExtraordinaryVillager.Skill.IDENTIFY);
        Villager warriv = new Villager("Warriv", 35);
        Villager flawia = new Villager("Flawia", 25);

        Villager[] villagers = {kashya, akara, gheed, deckardCain, warriv, flawia};

        for (Villager villager : villagers)
        {
            villager.sayHello();
        }

        Object objectDeckardCain = deckardCain;
        Object objectAkara = akara;

        while (Monsters.getMonstersHealth() > 0)
        {
            for (Villager villager : villagers)
            {
                if (Monsters.getMonstersHealth() <= 0)
                {
                    break;
                }

                Monster target = Monsters.getAndariel().getHealth() > 0 ? Monsters.getAndariel() : Monsters.getBlacksmith();

                System.out.println("Potwory posiadaja jeszcze " + Monsters.getMonstersHealth() + " punkty zycia");
                System.out.println("Aktualnie walczacy osadnik to " + villager.getName());

                if (villager.getHealth() > 0 && target.getHealth() > 0)
                {
                    villager.attack(target);
                }
            }
        }

        System.out.println("Obozowisko ocalone!");

        deckardCain = (ExtraordinaryVillager) objectDeckardCain;
        akara = (ExtraordinaryVillager) objectAkara;

        deckardCain.sayHello();
        akara.sayHello();
    }
}