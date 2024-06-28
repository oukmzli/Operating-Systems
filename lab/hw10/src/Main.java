import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

class ReadingRoom {
    // uzywamy zamku read/write z parametrem true co zapelni fairness (czesny dostep w kolejce
    // oczekiwania)
    private ReadWriteLock lock = new ReentrantReadWriteLock(true);
    private int readerCount = 0;
    private int capacity;

    public ReadingRoom(int capacity) {
        this.capacity = capacity;
    }

    public void startReading() throws InterruptedException {
        lock.readLock().lock(); // blokujemy readBlock
        try {
            while (readerCount == capacity) {
                // jesli czytelnia przepelniona - tymczasowo odblokowujemy read lock, zwalniamy
                // miejsca
                lock.readLock().unlock();
                synchronized (this) {
                    while (readerCount == capacity) {
                        wait(); // czekamy na notifyAll z stopReading
                    }
                }
                lock.readLock().lock(); // blokujemy z powrotem
            }
            readerCount++;
            System.out.println(Thread.currentThread().getName() + " <- IN");
        } finally {
            lock.readLock().unlock(); // ZAWSZE odblokowujemy readBlock
        }
    }

    public void stopReading() {
        lock.readLock().lock();
        try {
            readerCount--;
            System.out.println(Thread.currentThread().getName() + " <- OUT");
            if (readerCount == 0) {
                synchronized (this) {
                    notifyAll(); // powiadomiamy kazdy thread o braku czytelnikow
                }
            }
        } finally {
            lock.readLock().unlock();
        }
    }

    public void startWriting() throws InterruptedException {
        // blokujemy writeLock, co gwarantuje ze pisarz wyjdzie tylko gdy nie ma w czytelni zadnych
        // czytelnikow ani pisarza
        lock.writeLock().lock();
        System.out.println(Thread.currentThread().getName() + " <- IN");
    }

    public void stopWriting() {
        System.out.println(Thread.currentThread().getName() + " <- OUT");
        lock.writeLock().unlock(); // odblokowujemy writeLock
    }
}

// implements Runnable jest uzywany dla kazdej klasy, ktora uzywa threads
class Reader implements Runnable {
    private ReadingRoom room;

    public Reader(ReadingRoom room) {
        this.room = room;
    }

    public void run() {
        try {
            while (true) {
                room.startReading();
                Thread.sleep(300);
                room.stopReading();
                Thread.sleep(300);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

class Writer implements Runnable {
    private ReadingRoom room;

    public Writer(ReadingRoom room) {
        this.room = room;
    }

    public void run() {
        try {
            while (true) {
                room.startWriting();
                Thread.sleep(500);
                room.stopWriting();
                Thread.sleep(500);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

public class Main {
    public static void main(String[] args) {
        ReadingRoom room = new ReadingRoom(3);
        Thread[] readers = new Thread[5];
        Thread[] writers = new Thread[2];

        for (int i = 0; i < readers.length; i++) {
            readers[i] = new Thread(new Reader(room), "C " + i);
            readers[i].start();
        }

        for (int i = 0; i < writers.length; i++) {
            writers[i] = new Thread(new Writer(room), "P " + i);
            writers[i].start();
        }
    }
}