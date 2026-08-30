package efs.task.oop;

import lombok.Getter;

public class Monsters
{
    @Getter
    static final Monster andariel = new Monster(10, 70)
    {
        @Override
        public void takeHit(int damage)
        {
            this.health = Math.max(0, this.health - damage);
            monstersHealth = Math.max(0, monstersHealth - damage);
        }
    };

    @Getter
    static final Monster blacksmith = new Monster(100, 25)
    {
        @Override
        public void takeHit(int damage)
        {
            int actualDamage = 5 + damage;
            this.health = Math.max(0, this.health - actualDamage);
            monstersHealth = Math.max(0, monstersHealth - actualDamage);
        }
    };

    @Getter
    static int monstersHealth = andariel.getHealth() + blacksmith.getHealth();
}