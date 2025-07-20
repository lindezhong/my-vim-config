package ${group_id}.domain.model.demo1;

import ${group_id}.domain.model.demo1.Demo1.Demo1KeyIdentity;

public interface Demo1Repository {

    Demo1 find(Demo1KeyIdentity identity);

    void store(Demo1 demo);

}
