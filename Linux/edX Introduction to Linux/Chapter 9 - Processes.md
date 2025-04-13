
A **process** is simply an instance of one or more related tasks (threads) executing on your computer. It is not the same as a **program** or a **command**.



- kill a process - `kill -9 <pid>`

The priority for a process can be set by specifying a **nice value**, or niceness, for the process. The lower the nice value, the higher the priority.

- `renice +5 <pid>`

#### Load Averages

The load average can be viewed by running **w**, **top** or **uptime**. We will explain the numbers next.

```
milan ~  $ uptime
20:24  up 19 mins, 2 users, load averages: 2.40 4.81 10.13
```

The load average is displayed using three numbers (**2.40,** **4.81**, **10.13**):

- **2.40**: For the last minute the system has been 2.40 % utilized on average.
- **4.81**: For the last 5 minutes utilization has been 4.81 %.
- **10.13**: For the last 15 minutes utilization has been 10.13 %.

####  Background vs Foreground processes

 Foreground jobs run directly from the shell, and when one foreground job is running, other jobs need to wait for shell access (at least in that terminal window if using the GUI) until it is completed. By default, all jobs are executed in the foreground.

The background job will be executed at lower priority, which, in turn, will allow smooth execution of the interactive tasks, and you can type other commands in the terminal window while the background job is running.

You can use **CTRL-Z** to suspend a foreground job (i.e., put it in background) and **CTRL-C** to terminate it. You can always use the **bg** command to run a suspended process in the background, or the **fg** command to run a background process in the foreground.

#### Managing jobs

The **jobs** utility displays all jobs running in background. The display shows the job ID, state, and command name, as shown here.

**jobs -l** provides the same information as **jobs**, and adds the PID of the background jobs.

#### Listing Processes

- `ps`
- `top`, `atop`, `htop`
- `pstree`

#### Scheduling

- `at` - utility program to execute any non-interactive command **at** a specified time
- `cron` - is a time-based scheduling utility program. It can launch routine background jobs at specific times and/or days on an ongoing basis.
- `sleep`
- 
