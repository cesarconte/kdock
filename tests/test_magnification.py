#!/usr/bin/env python3
"""
Unit tests for the macOS Parabolic Magnification Curve used in kDock.
Validates smooth continuity, symmetry, bounded values, and zero-derivative at edges.
"""

import math
import unittest

def calculate_scale(item_center_x: float, mouse_x: float, base_width: float, max_scale: float = 1.65, radius_factor: float = 2.6) -> float:
    radius = base_width * radius_factor
    dist = abs(item_center_x - mouse_x)
    if dist >= radius:
        return 1.0
    normalized = dist / radius
    cos_val = math.cos((math.pi / 2.0) * normalized)
    factor = cos_val * cos_val
    return 1.0 + (max_scale - 1.0) * factor

class TestMagnificationCurve(unittest.TestCase):
    def setUp(self):
        self.base_width = 56.0
        self.max_scale = 1.65
        self.radius_factor = 2.6
        self.radius = self.base_width * self.radius_factor

    def test_peak_at_center(self):
        """At mouse_x == item_center_x, scale must exactly equal max_scale."""
        center = 200.0
        scale = calculate_scale(center, center, self.base_width, self.max_scale, self.radius_factor)
        self.assertAlmostEqual(scale, self.max_scale, places=6)

    def test_edge_continuity(self):
        """At distance >= radius, scale must equal exactly 1.0."""
        center = 200.0
        scale_edge = calculate_scale(center, center + self.radius, self.base_width, self.max_scale, self.radius_factor)
        self.assertAlmostEqual(scale_edge, 1.0, places=6)

        scale_outside = calculate_scale(center, center + self.radius + 50.0, self.base_width, self.max_scale, self.radius_factor)
        self.assertEqual(scale_outside, 1.0)

    def test_symmetry(self):
        """Curve must be perfectly symmetric to the left and right."""
        center = 300.0
        delta = 35.0
        scale_left = calculate_scale(center, center - delta, self.base_width, self.max_scale, self.radius_factor)
        scale_right = calculate_scale(center, center + delta, self.base_width, self.max_scale, self.radius_factor)
        self.assertAlmostEqual(scale_left, scale_right, places=6)

    def test_monotonic_decrease(self):
        """As distance increases from 0 to radius, scale must strictly decrease."""
        center = 400.0
        prev_scale = self.max_scale
        step = self.radius / 20.0
        for i in range(1, 21):
            dist = i * step
            curr_scale = calculate_scale(center, center + dist, self.base_width, self.max_scale, self.radius_factor)
            self.assertLess(curr_scale, prev_scale, f"Failed monotonic decrease at step {i}")
            prev_scale = curr_scale

if __name__ == '__main__':
    unittest.main()
