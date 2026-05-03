import torch
from torch_cluster import radius_graph

try:
    # Create dummy data on GPU
    # x: 10 atoms in 3D space
    x = torch.randn((10, 3)).cuda()
    batch = torch.zeros(10).long().cuda()
    
    print(f"Testing Blackwell (sm_121) compatibility...")
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    
    # This is the specific call that failed in DiffDock
    # It triggers the C++ geometric kernels
    edges = radius_graph(x, r=0.5, batch=batch)
    
    print("SUCCESS: Geometric kernels are Blackwell-compatible!")
    print(f"Edges found: {edges.shape[1]}")

except Exception as e:
    print("\nFAILED: Kernel mismatch detected.")
    print(f"Error: {e}")
    exit(1)
