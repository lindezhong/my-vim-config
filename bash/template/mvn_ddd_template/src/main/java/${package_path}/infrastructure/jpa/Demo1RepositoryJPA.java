package ${group_id}.infrastructure.jpa;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import ${group_id}.domain.model.demo1.Demo1;
import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;
import ${group_id}.domain.model.demo1.Demo1Repository;

public interface Demo1RepositoryJPA extends Demo1Repository, JpaRepository<Demo1, Long> {

    @Override
	default Demo1 find(Demo1KeyIdentity identity) {
        return findByKey(identity.getIdentity());
	}

    @Override
    default void store(Demo1 demo) {
        this.save(demo);
    }

    // 根据参数自动推断sql, 等价于 select d from Demo1 d where d.key = :key
    // 需要编译的是将方法元数据保留, 现在不可用
    // Demo1 findByKeyArg(String key);

    // 使用sql方式, 如果是修改需要添加注解@Modifying
    // @Modifying
    @Query(&quot;select d from Demo1 d where d.key = :key&quot;)
    Demo1 findByKey(String key);

    
}
