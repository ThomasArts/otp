%%
%% %CopyrightBegin%
%% 
%% Copyright Ericsson AB 2004-2014. All Rights Reserved.
%% 
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%% 
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%% 
%% %CopyrightEnd%
%%
%%

%%% Run like this:
%%%  ct:run_test([{suite,"ssh_property_test_SUITE"}, {logdir,"/ldisk/OTP/LOG"}]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                             %%%
%%%                       WARNING                               %%%
%%%                                                             %%%
%%% This is experimental code which may be changed or removed   %%%
%%%               anytime without any warning.                  %%%
%%%                                                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(ssh_property_test_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

all() -> [{group, messages},
	  {group, client_server}
	 ].

groups() ->
    [{messages, [], [decode,
		     decode_encode]},
     {client_server, [], [client_server_sequential,
			  client_server_parallel,
			  client_server_parallel_multi]}
    ].


%%% First prepare Config and compile the property tests for the found tool:
init_per_suite(Config) ->
    ct_property_test:init_per_suite(Config).

%%% One group in this suite happens to support only QuickCheck, so skip it
%%% if we run proper.
init_per_group(client_server, Config) ->
    case ?config(property_test_tool,Config) of
	proper ->
	    {skip, "PropEr is not supported"};
	eqc ->
	    Config
    end;
init_per_group(_, Config) ->
    Config.

end_per_group(_, Config) ->
    Config.

%%% Always skip the testcase that is not quite in phase with the
%%% ssh_message.erl code
init_per_testcase(decode_encode, _) -> {skip, "Fails - testcase is not ok"};
init_per_testcase(_TestCase, Config) -> Config.
    
end_per_testcase(_TestCase, Config) -> Config.

%%%================================================================
%%% Test suites
%%%
decode(Config) ->
    ct_property_test:quickcheck(
      ssh_eqc_encode_decode:prop_ssh_decode(),
      Config
     ).

decode_encode(Config) ->
    ct_property_test:quickcheck(
      ssh_eqc_encode_decode:prop_ssh_decode_encode(),
      Config
     ).

client_server_sequential(Config) ->
    ct_property_test:quickcheck(
      ssh_eqc_client_server:prop_seq(Config),
      Config
     ).

client_server_parallel(Config) ->
    ct_property_test:quickcheck(
      ssh_eqc_client_server:prop_parallel(Config),
      Config
     ).

client_server_parallel_multi(Config) ->
    ct_property_test:quickcheck(
      ssh_eqc_client_server:prop_parallel_multi(Config),
      Config
     ).
