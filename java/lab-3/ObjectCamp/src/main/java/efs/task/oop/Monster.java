package efs.task.oop;

import lombok.Getter;

@Getter
public abstract class Monster implements Fighter
{
    protected int health;
    protected final int damage;

    public Monster(int health, int damage)
    {
        this.health = health;
        this.damage = damage;
    }

    @Override
    public void attack(Fighter victim)
    {
        victim.takeHit(this.damage);
    }
}