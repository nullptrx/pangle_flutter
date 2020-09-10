package io.github.nullptrx.pangleflutter.util.imageloader;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class StreamUtils {

    public static void close(InputStream in) {
        try {
            if (in != null)
                in.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

        List<Integer> list = new ArrayList<>();
        list.add(1);

        List<Integer> lists = new ArrayList<>();
        list.add(1);

        List<Integer> listss = new ArrayList<>();
        list.add(1);

        Flow.from(list,lists).setComparator(new Flow.Comparator<Integer, Integer>() {
            @Override
            public boolean compare(Integer integer, Integer integer2) {
                return integer.equals(integer2);
            }
        }).setAction(new Flow.Action<Integer, Integer>() {
            @Override
            public void accept(Integer integer, Integer integer2) {
                integer = integer2;
            }
        }).forEach();
    }

    public static void close(OutputStream out) {
        try {
            if (out != null)
                out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
