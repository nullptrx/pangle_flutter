package io.github.nullptrx.pangleflutter.util.imageloader;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

/**
 * Created by admin on 17/6/21.
 */
public class Flow<T,R> {

    private List<T> srclist;
    private List<R> cmpList;
    private Comparator<T,R> comparator;
    private Action<T,R> action;

    public Flow(List<T> srclist,List<R> cmpList) {
        this.srclist = srclist;
        this.cmpList = cmpList;
    }

    public static <T,R> Flow<T,R> from(List<T> lists,List<R> cmpList){
        return new Flow<T,R>(lists,cmpList);
    }


    public Comparator getComparator() {
        return comparator;
    }

    public Flow<T,R> setComparator(Comparator<T,R> comparator) {
        this.comparator = comparator;
        return this;
    }

    public  void forEach(Action<T,R> action){
        this.action = action;
        forEach();
    }


    public  void forEach(){
        for (T t : srclist) {
            for (R r : cmpList) {
                if (comparator.compare(t,r)){
                    if (action !=null)
                        action.accept(t,r);
                }
            }
        }
    }

    public Action<T, R> getAction() {
        return action;
    }

    public Flow setAction(Action<T, R> action) {
        this.action = action;
        return this;
    }

    public interface Comparator<T,R>{
         boolean compare(T t, R r);
    }

    public interface Action<T,R>{
         void accept(T t, R r);
    }
}
