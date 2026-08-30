package efs.task.oop;

import lombok.Getter;

public class Villager implements Fighter
{
    protected int health;

    @Getter
    private final int age;
    @Getter
    private final String name;

    public Villager(String name, int age)
    {
        this.name = name;
        this.age = age;
        this.health = 100;
    }

    public int getHealth()
    {
        return this.health;
    }

    public int getDamage()
    {
        return (int) ((100 - this.age * 0.5) / 10);
    }

    public void sayHello()
    {
        System.out.println("Greetings traveler... I'm " + this.name + " and I'm " + this.age + " years old");
    }

    @Override
    public void attack(Fighter victim)
    {
        victim.takeHit(getDamage());
    }

    @Override
    public void takeHit(int damage)
    {
        this.health = Math.max(0, this.health - damage);
    }
}