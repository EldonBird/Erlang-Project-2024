-module(final).
-export([start_mailbox_server/0, user_input/2, printout/1, mailbox_server/1, start_client_server/0, client_server/0, start/0, user_interface/0, commander/1]).



start() ->
    start_mailbox_server(),
    start_client_server(),
    io:format("Client and Mailbox Server Started").

start_mailbox_server() ->
    
    global:register_name(mailbox_server_instance, spawn(?MODULE, mailbox_server, [[]])).




mailbox_server(Mailbox) ->
    receive
        {ClientPid, _Message, Request} when Request == 0 ->
            ClientPid ! Mailbox,
            mailbox_server(Mailbox);
        {ClientPid, Message, Request} when Request == 1 ->

            Current = Mailbox ++ [{ClientPid, date(), time(), Message}],
            ClientPid ! {"Message Sent"},
            mailbox_server(Current)
    end.


start_client_server() ->
    global:register_name(client_server_instance, spawn(?MODULE, client_server, [])).

client_server() ->

    receive
        {UserPid, Message, Request} ->
            Pid = global:whereis_name(mailbox_server_instance),               
            Pid ! {self(), Message, Request},
            receive
                Serverout ->
                    UserPid ! {Serverout}
            end,
        client_server() 
    end.


user_input(Message, Request) ->
    Pid = global:whereis_name(client_server_instance),

    Pid ! {self(), Message, Request},
    
    receive
        Responce when Request == 0 ->
            {Out} = Responce,
            printout(Out);

        Responce when Request == 1 ->
            Responce
    end.

user_interface() ->

    io:format("What would you like to do? (message, mailbox)"),
    Command = string:trim(io:get_line("")),
    commander(Command),
    user_interface().


commander("message") ->

    io:format("What would you like to send?"),
    Message = string:trim(io:get_line("")),
    final:user_input(Message, 1);

commander("mailbox") ->
    final:user_input("na", 0).



printout([]) -> ok;
printout([{Key, Date, Time, Value} | T]) -> io:format("User: ~p, Date: ~p, Time: ~p, Message: ~s~n", [Key, Date, Time, Value]), printout(T).

