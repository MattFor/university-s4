package efs.task.oop;

import lombok.Getter;

@Getter
public class ExtraordinaryVillager extends Villager
{

    public enum Skill
    {
        IDENTIFY("I will identify items for you at no charge."), SHELTER("I can offer you poor shelter.");

        private final String text;

        Skill(String text)
        {

            this.text = text;
        }

        public String getText()
        {

            return this.text;
        }
    }

    private final Skill skill;

    public ExtraordinaryVillager(String name, int age, Skill skill)
    {
        super(name, age);
        this.skill = skill;
    }

    @Override
    public void sayHello()
    {
        System.out.println("Greetings traveler... I'm " + getName() + " and I'm " + getAge() + " years old. " + this.skill.getText());
    }

    @Override
    public void attack(Fighter victim)
    {
        victim.takeHit(0);
    }

    @Override
    public void takeHit(int damage)
    {
        this.health = 0;
    }
}