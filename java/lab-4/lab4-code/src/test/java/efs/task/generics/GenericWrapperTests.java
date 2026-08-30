package efs.task.generics;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class GenericWrapperTests {

    @Test
    void wrappingCustomTypeWorks() {
        MyType myObject = new MyType();
        GenericWrapper<MyType> wrapper = GenericWrapper.create(myObject);
        assertThat(wrapper.getValue()).isEqualTo(myObject);
    }

    static class MyType {}
}
