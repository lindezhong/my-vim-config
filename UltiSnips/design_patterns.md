# 设计模式

## 资料
1. 官方代码: https://wickedlysmart.com/head-first-design-patterns/
2. github代码仓库: https://github.com/bethrobson/Head-First-Design-Patterns


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
    > 如果我们依靠继承,那么我们的行为只能在编译时静态地决定.  
    > 换句话说,我们只得到超类给我们的行为或者覆盖它们.  
    > 使用组合,我们可以用我们喜欢的方式在运行时混合与匹配
- 尽量做到交互对象之间的松耦合设计
- 开放-关闭原则: 类应该对扩展开放(继承,组合,委托等),但对修改关闭(无需修改已有的代码)
    > 我们的目标是允许类容易扩展以容纳新的行为,而不用修改已有的代码


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

### 观察者模式定义

定义对象之间的一对多依赖,这样一来,当一个对象改变状态时,它的所有依赖都会收到他嗯直并自动更新

#### 主题/观察者

```plantuml
@startuml

circle 主题对象 {}
note top of 主题对象 : 持有状态的对象(状态改变为8)

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
note right on link
当主题内的数据有改变,就会通知观察者
end note

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

### 观察者模式要点

1. 观察者模式定义对象之间的一对多关系
2. 主题使用通用接口更新观察者
3. 任何具体类型的观察者都可以参与该模式,只要它们实现观察者接口
4. 观察者是松耦合的,处理知道它们实现观察者接口之外,主题对它们的其他事情不知情.
5. 使用该模式时,你可以从主题推或拉数据(拉被认为更 "正确")
6. Swing 大量使用观察者模式,许多 GUI 框架也是这样
7. 你也会在其他很多地方发现该模式,包括 RxJava , JavaBeans 和 RMI , 以及其他语言的框架, 像 Cocoa , Swift 和 JavaScript 事件
8. 观察者模式和出版/订阅模式相关.出版/订阅模式用于更复杂得多主题和/或多消息类型的情形.
9. 观察者模式是一个常用的模式,当我们学习模型-视图-控制器(MVC)时,还会看到它

### 观察者模式探讨

1. 主题一有状态的变化就通知所有的观察者,但某个状态的变化只是部分观察者关心
2. 主题为啥不给特定的观察者状态变化而是把所有状态都给出去
3. 观察者为啥不主动拉取主题状态
4. 观察者不要依赖特的通知次序

### 观察者例子:气象观测站
有一个气象观测站需要追踪当前天气并且有个对象WeatherData追踪当前天气状况,WeatherData对象如下
```plantuml
@startuml

package "主题" #DDDDDD {
    interface Subject {
        + registerObserver()
        + removeObserver()
        + notifyObservers()
    }
    class WeatherData implements Subject {
        + registerObserver()
        + removeObserver()
        + notifyObservers()
    
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
    无论何时 WeatherData 更新了值
    measurementsChanged()方法被调用
    end note
}

package "观察者" #DDDDDD {
    interface DisplayElement {
        + display()
    }
    interface Observer {
        + update()
    }
    note top of Observer : 所有气象组件都实现 Observer 接口\n这样就给了 Subject 一个共同的接口\n当需要更新观察者时调用它
    Subject --> Observer : observers
    
       
    class CurrentConditionsDisplay implements Observer,DisplayElement {
        + update()
        + display() {//显示当前测量值}
    }
    CurrentConditionsDisplay --> WeatherData : subject
    
    class ThirdPartyDisplay implements Observer,DisplayElement {
        + update()
        + display() {//显示基于测量值的其他内容}
    }
    class StatisticsDisplay implements Observer,DisplayElement {
        + update()
        + display() {//显示平均值,最小值和最大测量值}
    }
    class ForecastDisplay implements Observer,DisplayElement {
        + update()
        + display() {//显示预报}
    }
}

@enduml
```

```java

public interface Subject {
    // 这两个方法都用一个Observer作为参数,即要注册或被移除的Observer
    public void registerObserver(Observer o);
    public void removeObserver(Observer o);
    // 当Subject的状态改变时,这个方法会被调用,以通知所有的观察者
    public void notifyObservers();
}

public interface Observer {
    // 这些都是当气象测量数据变化时观察者从Subject获取的状态值
    public void update(float temp, float humidity, float pressure);
}

// DisplayElement 接口只包含一个方法 display(), 当显示元素需要显示时,调用此方法
public interface DisplayElement {
    public void display();     
}


import java.util.*;
// WeatherData 实现 Subject 接口
public class WeatherData implements Subject {
    // 我们添加一个 List 来持有 Observer
    private List<Observer> observers;
    private float temperature;
    private float humidity;
    private float pressure;

    public WeatherData() {
        observers = new ArrayList<Observer>();
    }

    public void registerObserver(Observer o) {
        observers.add(o);
    }

    public void removeObserver(Observer o) {
        observers.remove(o);
    }

    public void notifyObservers() {
        for (Observer observer : observers) {
            observer.update(temperature, humidity, pressure);
        }
    }
   public void measurementsChanged() {
        notifyObservers();
    }

   // 模拟气象站测量到气象数据变化时候嗲用
    public void setMeasurements(float temperature, float humidity, float pressure) {
        this.temperature = temperature;
        this.humidity = humidity;
        this.pressure = pressure;
        measurementsChanged();
    }

    public float getTemperature() {
        return temperature;
    }

    public float getHumidity() {
        return humidity;
    }

    public float getPressure() {
        return pressure;
    }

}

// 这个接口实现了 Observer 方法所以它可以从 WeatherData 对象中获取变化
// 它也实现了 DisplayElement 因为我们的 API 打算要求所有显示元素实现这个接口
public class CurrentConditionsDisplay implements Observer, DisplayElement { 
    private float temperature;
    private float humidity;
    private WeatherData weatherData;
      
    public CurrentConditionsDisplay(WeatherData weatherData) { 
        this.weatherData = weatherData;
        weatherData.registerObserver(this);
    } 
      
    public void update(float temperature, float humidity, float pressure) { 
        this.temperature = temperature;
        this.humidity = humidity;
        display();
    } 
      
    public void display() { 
        System.out.println("Current conditions: " + temperature 
            + "F degrees and " + humidity + "% humidity");
    } 
}

// 测试程序
public class WeatherStation {
      
    public static void main(String[] args) {
        WeatherData weatherData = new WeatherData();
    
        CurrentConditionsDisplay currentDisplay = 
            new CurrentConditionsDisplay(weatherData);
        // StatisticsDisplay statisticsDisplay = new StatisticsDisplay(weatherData); 
        // ForecastDisplay forecastDisplay = new ForecastDisplay(weatherData);

        weatherData.setMeasurements(80, 65, 30.4f);
        weatherData.setMeasurements(82, 70, 29.2f);
        weatherData.setMeasurements(78, 90, 29.2f);
        
        weatherData.removeObserver(forecastDisplay);
        weatherData.setMeasurements(62, 90, 28.1f);
    }
}

```

### Java 内置的观察者模式

#### ~~Java Observer Observable 类~~

在 java9 中已经废弃不讨论

#### JavaBean PropertyChangeEvent

```java
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.io.Serializable;

public class PropertyChangeEventMain {

    public static void main(String[] args) {
        JavaBean bean = new JavaBean();

        bean.setId(1L);
        bean.setName("java bean 1");
        bean.setName("java bean 2");

        // id未发生变化不发送事件
        bean.setId(1L);
    }

    static class JavaBean implements PropertyChangeListener, Serializable {

        private Long id;
        private String name;

        private PropertyChangeSupport pcs = new PropertyChangeSupport(this);

        public JavaBean() {
            // 监听所有变化
            pcs.addPropertyChangeListener(this);
            // 只是监听 id 的变化
            pcs.addPropertyChangeListener("id", this);
            // 只是监听 name 的变化
            pcs.addPropertyChangeListener("name", this);
        }

        @Override
        public void propertyChange(PropertyChangeEvent evt) {
            System.out.println("property name is : " + evt.getPropertyName());
            System.out.println("old value is : " + evt.getOldValue());
            System.out.println("new value is : " + evt.getNewValue());
            System.out.println("======================");
        }
        public Long getId() {

        }

        public void setId(Long id) {
            Long oldId = this.id;
            this.id = id;

            // 发送 id 已经变更事件
            pcs.firePropertyChange("id", oldId, id);
        }

        public String getName() {
            return this.name;
        }

        public void setName(String name) {
            String oldName = this.name;
            this.name = name;

            // 发送 name 已经变更事件
            pcs.firePropertyChange("name", oldName, name);
        }
    }
}

```

## 装饰者模式

### 装饰者模式定义

***装饰者模式*** 动态地将额外责任附加到对象上.对于扩展功能,装饰者提供子类化之外的弹性替代方案

### 装饰者模式要点

1. 继承是扩展形式之一,但未必是达到弹性设计的最佳方式
2. 在我们的设计中,允许行为可以被扩展,而无需修改已有代码
3. 组合和委托经常可以用来运行时添加新行为
4. 装饰者模式提供了子类化扩展行为的替代品
5. 装饰者模式涉及一群装饰者类,这些类用来包装具体组件
6. 装饰者类反映了它们所装饰组件类型(事实上,它们和所装饰的组件类型相同,都经过了继承或接口实现)
7. 装饰者通过对组件的方法调用之前(或/和之后,甚至在那一刻)添加功能改变其组件的行为
8. 你可以用任意数目装饰者来包裹一个组件
9. 装饰者一般对组件的客户是透明的,除非客户依赖于组件的具体类型
10. 装饰者会导致设计中出现许多小对象,过度使用会让代码变得复杂

### 装饰者模式探讨

- 装饰者有着和所装饰对象相同的超类型
- 你可以用一个或多个装饰者包裹一个对象
- 鉴于装饰者有着和所装饰对象相同的超类型,在需要原始对象的场合,我们可以传递一个被装饰的对象
- ***装饰者在委托给所装饰对象之前或之后添加自己的行为,来在做剩下的工作***
- 对象可以在任何时候被装饰,因此我们可以在运行时用任意数量的装饰者动态地装饰对象,只要我们乐意
- 被装饰的对象尽量使用组合而不是继承,这样我们可以用我们喜欢的方式在运行时混合与匹配装饰者,而不是在编译时静态地决定
- 装饰者模式容易造成大量的小类(参考 java.io 类)
- 装饰者模式有类型问题:如果代码中依赖特定类型,如果引入装饰者就会出问题
    > 比如在starbuzz咖啡中如果 HouseBlend 作了类似打折的事情,一旦我用装饰者包裹 HouseBlend , 代码就不工作了  
    > 只是知道最外层的装饰者,比如对于starbuzz咖啡中如果一个带 Mocha,Soy,Whip的DarkRoast,编码时荣誉引用到Soy而不是Whip,这意味者订单中不包含Whip  
    > 无法户欧链条上的其他装饰,比如对于starbuzz咖啡中如果一个带 Mocha,Soy,Whip的DarkRoast,只是知道最外层
- 装饰者模式会增加实例化组件所需代码的复杂度,一旦用了装饰者,你不只要实例化组件,还要把它包裹进装饰者中
- 组件: 查看 [starbuzz咖啡类图](#starbuzz咖啡类图) 的Beverage注释和package咖啡/具体组件

### 与代理模式区别

TODO 代补充

### 装饰者模式例子: starbuzz咖啡

#### starbuzz咖啡类图

```plantuml
@startuml

abstract class Beverage {
    - String description

    + getDescription()
    + {abstract} cost()
    // 其他有用的方法()
}
note top of Beverage : Beverage 作为抽象组件

package "咖啡/具体组件" #DDDDDD {
    
    class HouseBlend extends Beverage {
        + cost()
    }
    note bottom of HouseBlend : 品类: 家常综合 \n 价格: $ .89

    class DarkRoast extends Beverage {
        + cost()
    }
    note bottom of DarkRoast : 品类: 深度烘培 \n 价格: $ .99
    
    class Espresso extends Beverage {
        + cost()
    }
    note bottom of Espresso : 品类: 低咖啡因 \n 价格: $ 1.05
    
    class Decaf extends Beverage {
        + cost()
    }
    note bottom of Decaf : 品类: 浓缩 \n 价格: $ 1.99
}

package "调料/装饰者" #DDDDDD {
    abstract class CondimentDecorator extends Beverage {
        - Beverage beverage
        
        + {abstract} getDescription()
    }
    note top of CondimentDecorator : 调料装饰者\n装饰者有着和所装饰对象相同的超类型
    note right of CondimentDecorator::beverage
    这里是对装饰者将包裹的 Beverage 的引用
    被装饰的对象尽量使用组合而不是继承
    这样我们可以用我们喜欢的方式在运行时混合与匹配装饰者
    而不是在编译时静态地决定
    end note
    note right of CondimentDecorator::getDescription
    我们打算要求所有调料装饰者都重新实现 getDescription() 方法
    我们希望描述不仅包含饮料也包含装饰饮料的每一样东西
    end note
    CondimentDecorator --> Beverage : 组件

    class Milk extends CondimentDecorator {
        + cost()
        + getDescription()
    }
    note bottom of Milk : 品类: 热奶 \n 价格: $ 0.10
    
    class Mocha extends CondimentDecorator {
        + cost()
        + getDescription()
    }
    note bottom of Mocha : 品类: 摩卡 \n 价格: $ 0.20

    class Soy extends CondimentDecorator {
        + cost()
        + getDescription()
    }
    note bottom of Soy : 品类: 豆奶 \n 价格: $ 0.15

    class Whip extends CondimentDecorator {
        + cost()
        + getDescription()
    }
    note bottom of Whip : 品类: 奶泡 \n 价格: $ 0.10

}

@enduml
```
#### 深度烘培摩卡奶泡 代码

```java

// 饮料
public abstract class Beverage {
    String description = "未知饮料";
  
    public String getDescription() {
        return description;
    }   
 
    public abstract double cost();
}

// 家常综合咖啡
public class HouseBlend extends Beverage {
    public HouseBlend() {
        description = "家常综合咖啡";
    }

    public double cost() {
        return .89;
    }
}

// 深度烘培咖啡
public class DarkRoast extends Beverage {
    public DarkRoast() {
        description = "深度烘培咖啡";
    }

    public double cost() {
        return .99;
    }
}

// 低咖啡因咖啡
public class Espresso extends Beverage {

    public Espresso() {
        description = "低咖啡因咖啡";
    }

    public double cost() {
        return 1.99;
    }
}

// 浓缩咖啡
public class Decaf extends Beverage {
    public Decaf() {
        description = "浓缩咖啡";
    }

    public double cost() {
        return 1.05;
    }
}

// 调料装饰者
public abstract class CondimentDecorator extends Beverage {
    Beverage beverage;

    // 我们打算要求所有调料装饰者都重新实现 getDescription() 方法
    // 我们希望描述不仅包含饮料也包含装饰饮料的每一样东西
    public abstract String getDescription();
}

// 热奶
public class Milk extends CondimentDecorator {
    public Milk(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", 热奶";
    }

    public double cost() {
        return .10 + beverage.cost();
    }
}

// 摩卡
public class Mocha extends CondimentDecorator {
    public Mocha(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", 摩卡";
    }

    public double cost() {
        return .20 + beverage.cost();
    }
}

// 豆奶
public class Soy extends CondimentDecorator {
    public Soy(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", 豆奶";
    }

    public double cost() {
        return .15 + beverage.cost();
    }
}

// 奶泡
public class Whip extends CondimentDecorator {
    public Whip(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", 奶泡";
    }

    public double cost() {
        return .10 + beverage.cost();
    }
}

// 下单测试代码
public class StarbuzzCoffee {

    public static void main(String args[]) {

        // 要一杯浓缩咖啡,不加调料,打印出他的描述和价格
        Beverage beverage = new Espresso();
        System.out.println(beverage.getDescription()
                + " $" + beverage.cost());

        // 做一个 深度烘培咖啡
        Beverage beverage2 = new DarkRoast();
        // 用一个摩卡包裹它
        beverage2 = new Mocha(beverage2);
        // 用第二个摩卡包裹它
        beverage2 = new Mocha(beverage2);
        // 用一个奶泡包裹它
        beverage2 = new Whip(beverage2);
        System.out.println(beverage2.getDescription()
                + " $" + beverage2.cost());

        // 给我们一份家常豆奶奶泡咖啡
        Beverage beverage3 = new HouseBlend();
        beverage3 = new Soy(beverage3);
        beverage3 = new Mocha(beverage3);
        beverage3 = new Whip(beverage3);
        System.out.println(beverage3.getDescription()
                + " $" + beverage3.cost());

        // 最后给我们一份 深度烘培摩卡奶泡卡咖啡
        Beverage beverage4 = new DarkRoast();
        beverage4 = new Mocha(beverage4);
        beverage4 = new Whip(beverage4);
        System.out.println(beverage4.getDescription()
                + " $" + beverage4.cost());


    }
}

```

#### 深度烘培摩卡奶泡咖啡 调用流程

```plantuml
@startuml

<> cost

package "Whip" <<Cloud>> #DDDDDD {
    () cost as WhipCost
    cloud Mocha {
        () cost as MochaCost
        package DarkRoast <<Cloud>> {
            () cost as DarkRoastCost
        }
    }
}

cost --> WhipCost
note top  on link
1. 首先,我们调用最外层装饰者 Whip上 的 cost()
end note

WhipCost --> MochaCost
note left on link
2. Whip 调用 Mocha上 的cost()
end note

MochaCost --> DarkRoastCost
note left on link
3.. Mocha 调用 DarkRoast 上的cost()
end note

MochaCost <-- DarkRoastCost : 0.99
note left on link
4. DarkRoast 返回其价值 99 美分
end note

WhipCost <-- MochaCost : 0.20
note left on link
5. Mocha 把自己的价钱 20 美分添加到来自 DarkRoast 的结果,并返回新的总计值 $ 1.19
end note
cost <-- WhipCost : 0.10
note right on link
6. Whip 把自己的总计 10 美分家到 Mocha 的返回值,并返回最终结果 $ 1.29
end note

@enduml
```

### 装饰者模式在java的应用 java.io

以 InputStream 为例
```plantuml
@startuml

interface InputStream {}

package "具体实现/具体组件" #DDDDDD {
    class FileInputStream implements InputStream {}
    class StringBufferInputStream implements InputStream {}
    class ByteArrayInputStream implements InputStream {}
}

package "装饰者" #DDDDDD {
    abstract FilterInputStream implements InputStream {}
    note top of FilterInputStream : FilterInputStream 是一个抽象装饰者

    class PushbackInputStream extends FilterInputStream {}
    class BufferedInputStream extends FilterInputStream {}
    class DataInputStream extends FilterInputStream {}
}

@enduml
```

```java
import java.io.*;              

// 把输入流中所有的大写字符转成小写
// 比如读入 "I know the Decorator Pattern therefore I RULE" -> "i know the decorator pattern therefore i rule" 
public class LowerCaseInputStream extends FilterInputStream {
  
    public LowerCaseInputStream(InputStream in) {
        super(in);             
    }
    
    public int read() throws IOException { 
        int c = in.read();
        return (c == -1 ? c : Character.toLowerCase((char)c));
    } 
        
    public int read(byte[] b, int offset, int len) throws IOException {
        int result = in.read(b, offset, len);
        for (int i = offset; i < offset+result; i++) {
            b[i] = (byte)Character.toLowerCase((char)b[i]);
        }
        return result;
    }
}

import java.io.*;

// 测试类
public class InputTest {
    public static void main(String[] args) throws IOException {
        int c;
        InputStream in = null;
        try {
            in =
                new LowerCaseInputStream(
                    new BufferedInputStream(
                        new FileInputStream("test.txt")));

            while((c = in.read()) >= 0) {
                System.out.print((char)c);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (in != null) { in.close(); }
        }
        System.out.println();
        try (InputStream in2 =
                new LowerCaseInputStream(
                    new BufferedInputStream(
                        new FileInputStream("test.txt"))))
        {
            while((c = in2.read()) >= 0) {
                System.out.print((char)c);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

```
