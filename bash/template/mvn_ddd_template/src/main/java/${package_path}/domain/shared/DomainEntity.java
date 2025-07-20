package ${group_id}.domain.shared;


/**
 * An entity
 * 
 */
public interface DomainEntity<E extends DomainEntity<E, ID>, ID extends Identity<?>> {

    /**
     * Entities compare by identity, not by attributes.
     *
     * @param other The other entity.
     * @return true if the identities are the same, regardless of other attributes.
     */
    default boolean sameIdentityAs(E other) {
        return other != null && other.getIdentity() != null 
            && other.getIdentity().equals(this.getIdentity());
    }

	/**
     * 获取身份标识, 对于 Entity 来说总有一个唯一标识
     *
	 * @return
	 */
	ID getIdentity();
}
