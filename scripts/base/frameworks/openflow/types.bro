module OpenFlow;

@load ./consts

export {
	## Available openflow plugins
	type Plugin: enum {
		## Internal placeholder plugin
		INVALID,
	};

	## Controller related state.
	## Can be redefined by plugins to
	## add state.
	type ControllerState: record {
		## Internally set to the plugin used.
		_plugin: Plugin;
	} &redef;

	## Openflow match definition.
	##
	## The openflow match record describes
	## which packets match to a specific
	## rule in a flow table.
	type ofp_match: record {
		# Input switch port.
		in_port: count &optional;
		# Ethernet source address.
		dl_src: string &optional;
		# Ethernet destination address.
		dl_dst: string &optional;
		# Input VLAN id.
		dl_vlan: count &optional;
		# Input VLAN priority.
		dl_vlan_pcp: count &optional;
		# Ethernet frame type.
		dl_type: count &optional;
		# IP ToS (actually DSCP field, 6bits).
		nw_tos: count &optional;
		# IP protocol or lower 8 bits of ARP opcode.
		nw_proto: count &optional;
		# At the moment, we store both v4 and v6 in the same fields.
		# This is not how OpenFlow does it, we might want to change that...
		# IP source address.
		nw_src: addr &optional;
		# IP destination address.
		nw_dst: addr &optional;
		# TCP/UDP source port.
		tp_src: port &optional;
		# TCP/UDP destination port.
		tp_dst: port &optional;
	};

	## Openflow flow_mod definition, describing the action to perform.
	type ofp_flow_mod: record {
		## Opaque controller-issued identifier.
		# This is optional in the specification - but let's force
		# it so we always can identify our flows...
		cookie: count; # &default=BRO_COOKIE_ID * COOKIE_BID_START;
		# Flow actions
		## Table to put the flow in. OFPTT_ALL can be used for delete,
		## to delete flows from all matching tables.
		table_id: count &optional;
		## One of OFPFC_*.
		command: ofp_flow_mod_command; # &default=OFPFC_ADD;
		## Idle time before discarding (seconds).
		idle_timeout: count &default=0;
		## Max time before discarding (seconds).
		hard_timeout: count &default=0;
		## Priority level of flow entry.
		priority: count &default=0;
		## For OFPFC_DELETE* commands, require matching entried to include
		## this as an output port. OFPP_ANY means no restrictions.
		out_group: count &optional;
		## Bitmap of the OFPFF_* flags
		flags: count &default=0;
		## Output ports to send data to.
		out_ports: vector of count &default=vector();
	};

# Functionality using this is currently not implemented. At all.
#	## Body of reply to OFPST_FLOW request.
#	type ofp_flow_stats: record {
#		## ID of table flow came from.
#		table_id: count;
#		## Description of fields.
#		match: ofp_match;
#		## Time flow has been alive in seconds.
#		duration_sec: count;
#		## Time flow has been alive in nanoseconds beyond
#		## duration_sec.
#		duration_nsec: count;
#		## Priority of the entry. Only meaningful
#		## when this is not an exact-match entry.
#		priority: count;
#		## Number of seconds idle before expiration.
#		idle_timeout: count;
#		## Number of seconds before expiration.
#		hard_timeout: count;
#		## Opaque controller-issued identifier.
#		cookie: count;
#		## Number of packets in flow.
#		packet_count: count;
#		## Number of bytes in flow.
#		byte_count: count;
#		## Actions
#		actions: vector of ofp_action_output;
#	};

	## Controller record representing an openflow controller
	type Controller: record {
		## Controller related state.
		state: ControllerState;
		## flow_mod function
		flow_mod: function(state: ControllerState, match: ofp_match, flow_mod: ofp_flow_mod): bool &optional;
		## flow_clear function
		flow_clear: function(state: ControllerState): bool &optional;
	};
}
