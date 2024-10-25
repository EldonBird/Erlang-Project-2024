-module(final).
-export([start_mailbox_server/0, user_input/2, printout/1, mailbox_server/1, start_client_server/0, client_server/0]).


start_mailbox_server() ->
    
    global:register_name(mailbox_server_instance, spawn(?MODULE, mailbox_server, [[]])).




mailbox_server(Mailbox) ->
    receive
        {ClientPid, _Message, Request} when Request == 0 ->
            ClientPid ! Mailbox,
            mailbox_server(Mailbox);
        {ClientPid, Message, Request} when Request == 1 ->
            Current = Mailbox ++ [Message],
            ClientPid ! "Success",
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
        Responce->
            printout(Responce)
    end.



printout([])-> io:format("No mail Today");
printout([H | T]) -> io:format(H), printout(T).
