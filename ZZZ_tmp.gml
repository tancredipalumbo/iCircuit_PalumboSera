<?xml version="1.0"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns&#10;http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd&quot;&gt;&#10;">
	<key for="node" attr.name="label" attr.type="string" id="label" />
	<key for="node" attr.name="x" attr.type="double" id="x" />
	<key for="node" attr.name="y" attr.type="double" id="y" />
	<key for="node" attr.name="size" attr.type="double" id="size" />
	<key for="node" attr.name="r" attr.type="int" id="r" />
	<key for="node" attr.name="g" attr.type="int" id="g" />
	<key for="node" attr.name="b" attr.type="int" id="b" />
	<key for="edge" attr.name="edgelabel" attr.type="string" id="edgelabel" />
	<key for="node" attr.name="width" attr.type="double" id="width" />
	<key for="node" attr.name="height" attr.type="double" id="height" />
	<key for="node" attr.name="shape" attr.type="string" id="shape" />
	<key for="node" attr.name="nodestroke" attr.type="string" id="nodestroke" />
	<key for="node" attr.name="nodestroketype" attr.type="int" id="nodestroketype" />
	<key for="node" attr.name="nodestrokewidth" attr.type="double" id="nodestrokewidth" />
	<key for="node" attr.name="nodefill" attr.type="int" id="nodefill" />
	<key for="node" attr.name="nodetype" attr.type="int" id="nodetype" />
	<key for="edge" attr.name="bends" attr.type="string" id="bends" />
	<key for="edge" attr.name="edgetype" attr.type="string" id="edgetype" />
	<key for="node" attr.name="clusterstroke" attr.type="string" id="clusterstroke" />
	<graph id="G" edgedefault="directed">
		<node id="0">
			<data key="label">1</data>
			<data key="x">45</data>
			<data key="y">45</data>
			<data key="width">2</data>
			<data key="height">2</data>
			<data key="size">2</data>
			<data key="shape">rect</data>
			<data key="r">255</data>
			<data key="g">255</data>
			<data key="b">255</data>
			<data key="nodefill">1</data>
			<data key="nodestroke">#000000</data>
			<data key="nodestroketype">1</data>
			<data key="nodestrokewidth">1</data>
			<data key="nodetype">0</data>
		</node>
		<node id="1">
			<data key="label">2</data>
			<data key="x">49</data>
			<data key="y">45</data>
			<data key="width">2</data>
			<data key="height">2</data>
			<data key="size">2</data>
			<data key="shape">rect</data>
			<data key="r">255</data>
			<data key="g">255</data>
			<data key="b">255</data>
			<data key="nodefill">1</data>
			<data key="nodestroke">#000000</data>
			<data key="nodestroketype">1</data>
			<data key="nodestrokewidth">1</data>
			<data key="nodetype">0</data>
		</node>
		<node id="2">
			<data key="label">3</data>
			<data key="x">45</data>
			<data key="y">41</data>
			<data key="width">2</data>
			<data key="height">2</data>
			<data key="size">2</data>
			<data key="shape">rect</data>
			<data key="r">255</data>
			<data key="g">255</data>
			<data key="b">255</data>
			<data key="nodefill">1</data>
			<data key="nodestroke">#000000</data>
			<data key="nodestroketype">1</data>
			<data key="nodestrokewidth">1</data>
			<data key="nodetype">0</data>
		</node>
		<node id="3">
			<data key="label">4</data>
			<data key="x">41</data>
			<data key="y">41</data>
			<data key="width">2</data>
			<data key="height">2</data>
			<data key="size">2</data>
			<data key="shape">rect</data>
			<data key="r">255</data>
			<data key="g">255</data>
			<data key="b">255</data>
			<data key="nodefill">1</data>
			<data key="nodestroke">#000000</data>
			<data key="nodestroketype">1</data>
			<data key="nodestrokewidth">1</data>
			<data key="nodetype">0</data>
		</node>
		<edge id="0" source="0" target="1">
			<data key="edgelabel">1</data>
			<data key="bends">45 45 49 45 </data>
			<data key="edgetype">association</data>
		</edge>
		<edge id="1" source="2" target="3">
			<data key="edgelabel">2</data>
			<data key="bends">45 41 41 41 </data>
			<data key="edgetype">association</data>
		</edge>
		<edge id="2" source="2" target="1">
			<data key="edgelabel">3</data>
			<data key="bends">45 41 49 41 49 45 </data>
			<data key="edgetype">association</data>
		</edge>
		<edge id="3" source="2" target="0">
			<data key="edgelabel">4</data>
			<data key="bends">45 41 45 45 </data>
			<data key="edgetype">association</data>
		</edge>
		<edge id="4" source="0" target="3">
			<data key="edgelabel">5</data>
			<data key="bends">45 45 41 45 41 41 </data>
			<data key="edgetype">association</data>
		</edge>
	</graph>
</graphml>
