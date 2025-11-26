# FlakeEssentials Circuit Breaker Configuration
# 
# Set 'true' to keep an essential anchored (protected from garbage collection)
# Set 'false' to allow it to be collected when no projects are using it
#
# This is the ONLY file you need to edit to manage your essentials.

{
  # JavaScript/Node.js development environment
  js = false;

  # Python base environment (without ML dependencies)
  pythonBase = false;

  # Python with Machine Learning (CUDA, TensorFlow, PyTorch, etc)
  # Warning: This is large (~5GB+) and compilation-intensive
  pythonML = true;

  # Add more essentials here as they are created
  # rust = false;
  # go = false;
  # haskell = false;
}
