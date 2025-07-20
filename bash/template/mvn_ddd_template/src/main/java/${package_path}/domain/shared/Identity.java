package ${group_id}.domain.shared;

/**
 * 唯一标识, 它是一个ValueObject 
 */
public interface Identity<T> extends ValueObject<T> {

    /**
     * 基本类型的identity, ID需要为基本类型, 比如int, String 等
     */
    class BaseIdentity<ID> implements Identity<BaseIdentity<ID>> {

        private ID identity;
   
		public BaseIdentity(ID identity) {
			this.identity = identity;
		}

		@Override
    	public boolean sameValueAs(BaseIdentity<ID> other) {
            return other != null && other.identity != null
                && this.identity != null
                && other.identity == this.identity;
    	}
 
    	public ID getIdentity() {
			return identity;
		}

    }

    /**
     * String 类型的identity
     */
    public class StringIdentity extends BaseIdentity<String> {
		public StringIdentity(String identity) {
			super(identity);
		}
    }

    /**
     * int 类型的identity
     */
    public class IntIdentity extends BaseIdentity<Integer> {

		public IntIdentity(Integer identity) {
			super(identity);
		}
    }


    /**
     * long 类型的identity
     */
    public class LongIdentity extends BaseIdentity<Long> {

		public LongIdentity(Long identity) {
			super(identity);
		}
    }

}


