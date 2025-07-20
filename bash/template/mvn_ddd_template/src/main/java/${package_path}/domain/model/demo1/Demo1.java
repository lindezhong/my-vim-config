package ${group_id}.domain.model.demo1;

import ${group_id}.domain.shared.DomainEntity;
import ${group_id}.domain.shared.Identity.StringIdentity;
import ${group_id}.domain.shared.ValueObject;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

import java.util.Objects;


import org.apache.commons.lang3.builder.EqualsBuilder;

import ${group_id}.domain.shared.AbstractSpecification;
import ${group_id}.domain.shared.AggregateRoot;
import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;;

@Entity(name = &quot;Demo1&quot;)
@Table(name = &quot;demo1&quot;)
// Demo1KeyIdentity 继承 StringIdentity
public class Demo1 implements DomainEntity<Demo1, Demo1KeyIdentity>, AggregateRoot {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private long id;

    // 设置唯一键
    @Column(name = &quot;demo_key&quot;, unique = true)
    private String key;

    // 枚举测试
    @Enumerated(value = EnumType.STRING)
    @Column(name = &quot;demo_type&quot;)
    private Type type;

    // 这个字段还是在表Demo1中, 只是这些字段转成了value类
    @Embedded
    private Value value;

    // 关联其他表, 关系可以 1对1, 1对多, 多对1, 多对多
    // @OneToMany
    // @ManyToMany
    // @ManyToOne
    @OneToOne(optional = true, cascade = CascadeType.ALL)
    @JoinColumn(name = &quot;relation_id&quot;)
    private Relation relation;

    // 规格测试, 这个规格判断是否为当前类型
    @Embedded
    private TypeSpecification typeSpecification;

	public Demo1(String key, Type type, Value value, Relation relation, TypeSpecification typeSpecification) {
		this.key = key;
		this.type = type;
		this.value = value;
		this.relation = relation;
		this.typeSpecification = typeSpecification;
	}

    protected Demo1() { }

	@Override
	public Demo1KeyIdentity getIdentity() {
        return new Demo1KeyIdentity(key);
	}

    // Entity 和 ValueObject 最好都覆盖 equals
    @Override
    public boolean equals(Object obj) {
        return this.sameIdentityAs((Demo1) obj);
    }

    public static class Demo1KeyIdentity extends StringIdentity {

		public Demo1KeyIdentity() {
            super(&quot;&quot;);
		}


		public Demo1KeyIdentity(String identity) {
			super(identity);
		}
    }

    // 关联表可以是 ValueObject 也可以是 Entity
    @Entity(name = &quot;Relation&quot;)
    @Table(name = &quot;relation&quot;)
    public static class Relation implements ValueObject<Relation> {

        @Id
        @GeneratedValue(strategy = GenerationType.AUTO)
        private long id;

        @Column(name = &quot;remark&quot;)
        private String remark;

        public Relation(String remark) {
			this.remark = remark;
		}

        protected Relation() { }

		@Override
        public boolean sameValueAs(Relation other) {
            return other != null && new EqualsBuilder()
                .append(this.remark, other.remark)
                .isEquals();
        }

		public long getId() {
			return id;
		}

		public String getRemark() {
			return remark;
		}
    }

    @Embeddable
    public static class TypeSpecification extends AbstractSpecification<Type> implements ValueObject<TypeSpecification> {

        @Enumerated(value = EnumType.STRING)
        @Column(name = &quot;original_type&quot;)
        private Type type;

		public TypeSpecification(Type type) {
			this.type = type;
		}

        protected TypeSpecification() {}

		@Override
		public boolean sameValueAs(TypeSpecification other) {
            return other != null && new EqualsBuilder()
                .append(this.type, other.type)
                .isEquals();
		}

		@Override
		public boolean isSatisfiedBy(Type t) {
            return Objects.equals(this.type, t);
		}

		public Type getType() {
			return type;
		}
    }

    @Embeddable
    public static class Value implements ValueObject<Value> {

        @Column(name = &quot;content&quot;)
        private String content;

        @Column(name = &quot;author&quot;)
        private String author;

        public Value(String content, String author) {
			this.content = content;
			this.author = author;
		}

        protected Value() {}

		@Override
        public boolean sameValueAs(Value other) {
            return other != null && new EqualsBuilder()
                .append(this.content, other.content)
                .append(this.author, other.author)
                .isEquals();

        }

        @Override
        public boolean equals(Object obj) {
            return this.sameValueAs((Value)obj);
        }

		public String getContent() {
			return content;
		}

		public String getAuthor() {
			return author;
		}


    }

    public enum Type implements ValueObject<Type> {
		ONE(&quot;one&quot;), TWO(&quot;two&quot;);
        private String type;

		private Type(String type) {
			this.type = type;
		}

		@Override
		public boolean sameValueAs(Type other) {
            return this.equals(other);
		}
    }

	public long getId() {
		return id;
	}

	public String getKey() {
		return key;
	}

	public Type getType() {
		return type;
	}

	public Value getValue() {
		return value;
	}

	public Relation getRelation() {
		return relation;
	}

	public TypeSpecification getTypeSpecification() {
		return typeSpecification;
	}


}


