# Pipe implementation in our custom shell
A pipe in system programming is a way to forward the standard output
of a program to the standard input of another one.

When running this command in our custom shell using this symbol `|`,
we want the output of `echo` to be used as the input of `toupper`
which is just going to print the text in uppercase.
```sh
echo hello | toupper
```

To test if the output sent through a pipe reaches `toupper`, 
you can run the script `./st`, you can ignore all lines before
`SO3: starting the initial process (shell)`
Once you see the prompt `so3%`, you can type a command.

```sh
so3% echo hello | toupper
HELLO
```

```sh
so3% type ls | toupper
CAT.ELF
ECHO.ELF
LN.ELF
LS.ELF
SH.ELF
```

To exit the shell, you have to enter `Ctrl+x a`,
this will exit the Qemu hypervisor.

