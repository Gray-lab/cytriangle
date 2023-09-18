from libc.stdlib cimport free, malloc
import numpy as np
from cytriangle.ctriangle cimport triangulateio

cdef class TriangleIO:

    def __cinit__(self):
        # Initialize the triangulateio struct with NULL pointers
        self._io = <triangulateio*> NULL

    def __dealloc__(self):
        # Free allocated memory when the instance is deallocated
        if self._io is not NULL:
            # add all the allocation releases
            if self._io.pointlist is not NULL:
                free(self._io.pointlist)
            if self._io.pointattributelist is not NULL:
                free(self._io.pointattributelist)
            if self._io.pointmarkerlist is not NULL:
                free(self._io.pointmarkerlist)
            if self._io.trianglelist is not NULL:
                free(self._io.trianglelist)
            if self._io.triangleattributelist is not NULL:
                free(self._io.triangleattributelist)
            if self._io.trianglearealist is not NULL:
                free(self._io.trianglearealist)
            if self._io.neighborlist is not NULL:
                free(self._io.neighborlist)
            if self._io.segmentlist is not NULL:
                free(self._io.segmentlist)
            if self._io.segmentmarkerlist is not NULL:
                free(self._io.segmentmarkerlist)
            if self._io.holelist is not NULL:
                free(self._io.holelist)
            if self._io.regionlist is not NULL:
                free(self._io.regionlist)
            if self._io.edgelist is not NULL:
                free(self._io.edgelist)
            if self._io.edgemarkerlist is not NULL:
                free(self._io.edgemarkerlist)
            if self._io.normlist is not NULL:
                free(self._io.normlist)
            free(self._io)

    def __init__(self, input_dict=None):
        # Assemble the triangulateio struct from a Python dictionary
        if self._io is NULL:
            self._io = <triangulateio*> malloc(sizeof(triangulateio))

        # Allocate null fields
        # input - always set
        # output - initialized unless N
        self._io.pointlist = <double*> NULL
        self._io.numberofpoints = 0

        # input - optional
        self._io.pointattributelist = <double*> NULL
        self._io.numberofpointattributes = 0
        # output - not N and nonzero numberofpointattributes
        self._io.pointmarkerlist = <int*> NULL

        # input - r switch
        self._io.trianglelist = <int*> NULL
        self._io.numberoftriangles = 0
        self._io.numberofcorners = 0
        self._io.numberoftriangleattributes = 0
        self._io.triangleattributelist = <double*> NULL

        # input - a switch
        self._io.trianglearealist = <double*> NULL

        self._io.neighborlist = <int*> NULL

        # input - p switch
        self._io.segmentlist = <int*> NULL
        self._io.segmentmarkerlist = <int*> NULL
        self._io.numberofsegments = 0

        # input - p switch without r
        self._io.holelist = <double*> NULL
        self._io.numberofholes = 0
        self._io.regionlist = <double*> NULL
        self._io.numberofregions = 0

        # input - always ignored
        self._io.edgelist = <int*> NULL
        self._io.edgemarkerlist = <int*> NULL
        self._io.normlist = <double*> NULL
        self._io.numberofedges = 0

        # Populate based on input_dict
        if input_dict is not None:
            if input_dict['point_list']:
                self.set_points(input_dict['point_list'])

    def to_dict(self):
        output_dict = {}
        num_points = self._io.numberofpoints
        num_attrs = self._io.numberofpointattributes
        num_triangles = self._io.numberoftriangles
        num_neighbors = self._io.numberofcorners
        num_triangle_attrs = self._io.numberoftriangleattributes
        num_segments = self._io.numberofsegments
        num_holes = self._io.numberofholes
        num_regions = self._io.numberofregions
        num_edges = self._io.numberofedges

        if self._io.pointlist is not NULL:
            output_dict['point_list'] = [[self._io.pointlist[2*i], self._io.pointlist[2*i + 1]] for i in range(num_points)]

        if self._io.pointattributelist is not NULL:
            output_dict['point_attribute_list'] = []
            for i in range(num_points):
                point_attr = []
                for j in range(num_attrs):
                    point_attr.append(self._io.pointattributelist[i*num_attrs + j ])
                output_dict['point_attribute_list'].append(point_attr)

        if self._io.pointmarkerlist is not NULL:
            output_dict['point_marker_list'] = [self._io.pointmarkerlist[i] for i in range(num_points)]

        if self._io.trianglelist is not NULL:
            output_dict['triangle_list'] = [self._io.trianglelist[i] for i in range(num_triangles)]

        if self._io.triangleattributelist is not NULL:
            output_dict['triangle_attribute_list'] = []
            for i in range(num_triangles):
                triangle_attr = []
                for j in range(num_attrs):
                    triangle_attr.append(self._io.triangleattributelist[i*num_attrs + j ])
                output_dict['triangle_attribute_list'].append(triangle_attr)

        if self._io.trianglearealist is not NULL:
            output_dict['triangle_area_list'] = [self.trianglearealist[i] for i in range(num_triangles)]

        if self._io.neighborlist is not NULL:
            neighbor_list = []
            for i in range(num_triangles):
                neighbors = [self._io.neighborlist[i*num_neighbors + j] for j in range(num_neighbors)]
                neighbor_list.append(neighbors)
            output_dict['neighbor_list'] = neighbor_list

        if self._io.segmentlist is not NULL:
            output_dict['segment_list'] = []
            for i in range(num_segments):
                start_pt_index = self._io.segmentlist[2*i]
                end_pt_index = self._io.segmentlist[2*i + 1]
                output_dict['segment_list'].append([start_pt_index, end_pt_index])

        if self._io.segmentmarkerlist is not NULL:
            output_dict['segment_marker_list'] = [self._io.segmentmarkerlist[i] for i in range(num_segments)]

        if self._io.holelist is not NULL:
            output_dict['hole_list'] = [[self._io.holelist[2*i], self._io.holelist[2*i + 1]] for i in range(num_holes)]

        if self._io.regionlist is not NULL:
            output_dict['region_list'] = []

            for i in range(num_regions):
                region_info = {}
                region_info['points'] = [self._io.regionlist[4*i], self._io.regionlist[4*i + 1]]
                region_info['max_area'] = self.io.regionlist[4*i + 2]
                region_info['attribute'] = self._io.regionlist[4*i + 3]

            output_dict['region_list'].append(region_info)

        if self._io.edgelist is not NULL:
            output_dict['edge_list'] = []

            for i in range(num_edges):
                edge_info = {}
                edge_info['points'] = [self._io.edgelist[2*i], self._io.edgelist[2*i + 1]]
                edge_info['marker'] = self._io.edgemarkerlist[i]

            output_dict['edge_list'].append(edge_info)

        if self._io.edgemarkerlist is not NULL:
            output_dict['edge_marker_list'] = [self._io.edgemarkerlist[i] for i in range(num_edges)]

        if self._io.normlist is not NULL:
            output_dict['norm_list'] = [[self._io.normlist[4*i], self._io.normlist[4*i + 1], self._io.normlist[4*i + 2], self._io.normlist[4*i + 3]] for i in range(num_edges)]

        return output_dict

    @property
    def point_list(self):
        return [[self._io.pointlist[2*i], self._io.pointlist[2*i + 1]] for i in range(self._io.numberofpoints)]

    @point_list.setter
    def point_list(self, points):
        self.set_points(points)

    def set_points(self, points):
        num_points = len(points)
        self._io.numberofpoints = num_points
        if num_points < 3:
            raise ValueError('Valid input requires three or more points')
        point_list = np.ascontiguousarray(points, dtype=np.double)
        self._io.pointlist = <double*>malloc(2 * num_points * sizeof(double))
        for i in range(num_points):
            self._io.pointlist[2 * i] = point_list[i, 0]
            self._io.pointlist[2 * i + 1] = point_list[i, 1]
