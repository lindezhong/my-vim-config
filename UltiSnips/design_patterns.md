# 设计模式


## OO(面向对象)基础知识

### OO基础

- 抽象
- 封装
- 多态
- 继承

### OO原则/设计原则

- 封装变化: 识别应用中变化的方面,把它们和不变的方面分开
- 针对接口编程,而不是针对实现编程
    > 针对接口编程真正的意思是针对超类型编程.  
    > 接口一词在这里有多个含义.  接口是一个概念也是java的一个构造.  针对接口编程不必真的使用java的接口.  
    > 要点是通过针对超类型编程来利用多态,这样实际的运行时对象不会被锁定到代码  
- 优先使用组合而不是继承
- 尽量做到交互对象之间的松耦合设计


## 策略模式
策略模式: 定义了一个算法族,分别封装起来,是的他们之间可以相互变换.策略让算法的变化独立使用它的客户

### 策略模式例子:鸭塘模拟游戏
下面例子中鸭子(客户)使用了算法(飞行行为,鸭子行为),不同实现用于替换

joe上班的公司做了一款相当成功的鸭塘模拟游戏SimUDuck.游戏中会出现各种鸭子,一边戏水,一边嘎嘎叫.
```plantuml
@startuml
page 1x10
package "封装的飞行行为" #DDDDDD {
    
    interface FlyBehavior {
        + void fly()
    }

    note top of FlyBehavior : 飞行接口
    class FlyWithWings implements FlyBehavior {
    }
    note bottom of FlyWithWings : 实现鸭子飞行
    class FlyNoWay implements FlyBehavior {
    }
    note bottom of FlyNoWay : 什么都不做不会飞
}

package "封装的鸭子行为" #DDDDDD {
    interface QuackBehavior {
        + void quack()
    }
    note top of QuackBehavior : 嘎嘎叫接口
    class Quack implements QuackBehavior {
    }
    note bottom of Quack : 实现鸭子的嘎嘎叫\n真的嘎嘎叫
    class Squeak implements QuackBehavior {
    }
    note bottom of Squeak : 橡皮鸭嘎嘎叫\n名为嘎嘎叫\n实为啊啊叫
    class MuteQuack implements QuackBehavior {
        + void quack()
    }
    note bottom of MuteQuack : 名为嘎嘎叫\n其实不出声
}
package "鸭子" #DDDDDD {
    abstract class Duck {
        - FlyBehavior flyBehavior
        - QuackBehavior quackBehavior
        
        + void setFlyBehavior(FlyBehavior flyBehavior)
        + void setQuackBehavior(QuackBehavior quackBehavior)
        + void performQuack()
        + void swim()
        + void display()
        + performFly()
    }

    note left of Duck::setFlyBehavior
        修改飞行行为
    end note
    note left of Duck::setQuackBehavior
        修改嘎嘎叫行为
    end note
    note "行为变量声明为行为'接口'类型" as N1
    N1 --> Duck::flyBehavior #000000
    N1 --> Duck::quackBehavior #000000

    note "这些方法取代fly()和quack()" as N2
    N2 --> Duck::performQuack #000000
    N2 --> Duck::performFly #000000

    
    FlyBehavior <-- Duck
    QuackBehavior <-- Duck

    class MallardDuck extends Duck {}
    note bottom of MallardDuck : 野鸭会嘎嘎叫也会飞行
    class RedheadDuck extends Duck {}
    note bottom of RedheadDuck : 红发鸭所有行为更野鸭一样处理外观
    class RubberDuck extends Duck {}
    note bottom of RubberDuck : 橡皮鸭会啊啊叫但不会飞行
    class DecoyDuck extends Duck {}
    note bottom of DecoyDuck : 诱饵鸭会嘎嘎叫但不会飞行
}
@enduml

```

```java

// 叫声行为
public interface QuackBehavior {
    public void quack();
}
public class Quack implements QuackBehavior {
    public void quack() {
        System.out.println("Quack");
    }
}
public class MuteQuack implements QuackBehavior {
    public void quack() {
        System.out.println("<< Silence >>");
    }
}
public class Squack implements QuackBehavior {
    public void quack() {
        System.out.println("Squack");
    }
}

// 飞行行为
public interface FlyBehavior {
    public void fly();
}
public class FlyWithWings implements FlyBehavior {
    public void fly() {
        System.out.println("fly");
    }
}
public class FlyNoWay implements FlyBehavior {
    public void fly() {
        System.out.println("not fly");
    }
}


// 鸭子抽象类
public abstract class Duck {
    protected QuackBehavior quackBehavior;
    protected FlyBehavior flyBehavior;
    
    public void setFlyBehavior(FlyBehavior flyBehavior) {
        this.flyBehavior = flyBehavior;
    }
    public void setQuackBehavior(QuackBehavior quackBehavior) {
        this.quackBehavior = quackBehavior;
    }

    // 为了执行嘎嘎叫,Duck只要让quackBehavior所引用的对象为嘎嘎叫即可.
    // 在这部分代码中我们不关心具体Duck是那种对象
    // 只要它知道这么quack()就可以了
    public void performQuack() {
        quackBehavior.quack();
    }

    public void performFly() {
        flyBehavior.fly();
    }

    // 识别应用中变化的方面,把它们和不变的方面分开
    public abstract void swim() {
        System.out.println("所有的鸭子都会漂浮，甚至是游泳");
    }
    public abstract void display();

}

// 野鸭会嘎嘎叫也会飞行
public class MallardDuck extends Duck {
    // 实例化Duck的quackBehavior flyBehavior
    public MallardDuck() {
        // MallardDuck 使用Quack类来处理嘎嘎叫,因此 performQuack() 被调用时,嘎嘎叫的责任被委托给Quack对象我们得到了真正的嘎嘎叫
        this.quackBehavior = new Quack();
        this.flyBehavior = new FlyWithWings();
    }

    public void display() {
        System.out.println("我是一个红色的野鸭");
    }
}


// 测试类
public class MiniDuckSimulator {
    public static void main(String[] args) {
        Duck mallard = new MallardDuck();
        mallard.performQuack(); // 输出 Quack
        mallard.performFly(); // 输出 fly

        // 改变为不会飞行
        mallard.setFlyBehavior(new FlyNoWay());
        mallard.performFly(); // 输出 not fly
    }
}

```

## 观察者模式

### 观察者摸索定义

定义对象之间的一对多依赖,这样一来,当一个对象改变状态时,它的所有依赖都会收到他嗯直并自动更新

#### 主题/观察者

```plantuml
@startuml

circle 主题对象 {}
note top of 主题对象 : 持有状态的对象(状态为8)

package "观察者" <<Cloud>> #DDDDDD {
    circle mouse {}
    circle dog {}
    circle duck {}
    circle cat {}
}

主题对象 --> mouse : 8
主题对象 --> dog : 8
主题对象 --> duck : 8
主题对象 --> cat : 8

@enduml
```

主题和和观察者定义了一对多关系.当主题有变化时,会通知众多观察者.观察者是主题的依赖者,当主题的状态变化,观察者被通知.

观察者模式有几种不同的实现方式,但大多数围绕着包括主题和观察者接口的类设计

#### 观察者模式类图

```plantuml
@startuml
interface Subject {
    + registerObserver()
    + removeObserver()
    + notifyObservers()
}
note right of Subject : 这是主题接口.\n对象使用这个接口注册为观察者,\n或把自己从观察者中移除

interface Observer {
    + update()
}
note right of Observer : 所有潜在的观察者需要实现观察者接口.\n这个接口只有方法update(),\n当主题状态改变时被调用

Subject "1" --> "n" Observer : 每个主题可以有许多观察者

class ConcreteSubject implements Subject {
    + registerObserver() {...}
    + removeObserver() {...}
    + notifyObservers() {...}

    + getState()
    + setState()
}
note bottom of ConcreteSubject 
一个具体的主题总是实现Subject(主题)接口
除了注册和移除方法,具体主题还实现了notifyObservers()方法
此方法用于在状态改变时更新当前所有观察者
end note
note right of ConcreteSubject::setState
具体主题也可能有设置和独具状态的方法
end note

class ConcreteObserver implements Observer {
    + update()
    // 其他观察者方法()
}
note bottom of ConcreteObserver : 具体观察者可以是实现观察者接口的类\n每个观察者注册具体主题以接收更新
ConcreteSubject --> ConcreteObserver

@enduml
```

### 观察者例子:气象观测站
有一个气象观测站需要追踪当前天气并且有个对象WeatherData追踪当前天气状况,WeatherData对象如下
```plantuml
@startuml
class WeatherData {
    + getTemperature()
    + getHumidity()
    + getPressure()
    + measurementsChanged()
}
note "这三个方法返回最近的气候测量,分别为温度,湿度,气压" as N1
N1 --> WeatherData::getTemperature #000000
N1 --> WeatherData::getHumidity #000000
N1 --> WeatherData::getPressure #000000
note left of WeatherData::measurementsChanged()
无论何时 WeatherData 更新了值,measurementsChanged()方法被调用
end note
@enduml
```
