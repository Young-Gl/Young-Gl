---
title: 知道一点点 · Knowing a Little
date: 2026-11-10
summary: 从完全不知道,变成知道一点点。
---

夜里风扇突然转起来,我第一反应是打开活动监视器。它告诉我 CPU 占用 12%,然后就没有别的了。

12% 说明不了什么。是哪个核在算?在算什么?我没法知道。

后来我去读 SMC 的键值,`PSTR` 那一项是整机功耗,单位瓦。把它放进菜单栏之后,我至少能判断是充电器在供电,还是电池在放电。

但这其实没解决什么。风扇该转还是转,我通常还是不知道原因。只是从「完全不知道」,变成了「知道一点点」。

---

**Knowing a Little**

The fan spun up at night and my first move was Activity Monitor. It said 12% CPU, and that was all it said.

Twelve percent doesn't tell you which core, or what it's doing. I had no way to find out.

So I went and read the SMC keys. `PSTR` is total system power, in watts. Once that number sat in the menu bar, I could at least tell whether the charger was supplying the machine or the battery was.

It didn't fix anything. The fan still spins, and I usually still don't know why. It just moved me from knowing nothing to knowing a little.
