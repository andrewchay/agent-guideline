#!/bin/bash
# Run Agent Evaluations
# Usage: ./run-evals.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SUITE=""
TASK=""
TRIALS=3
CONFIG="evals/config.yaml"
VERBOSE=false

# Help message
show_help() {
    cat << EOF
Run Agent Evaluations

Usage: $0 [OPTIONS]

Options:
    -s, --suite SUITE       Run a specific test suite (coding, research, customer_support)
    -t, --task TASK         Run a specific task (e.g., coding/create_mcp_server)
    -n, --trials N          Number of trials per task (default: 3)
    -c, --config FILE       Config file path (default: evals/config.yaml)
    -v, --verbose           Verbose output
    -h, --help              Show this help message

Examples:
    $0                              # Run all evaluations
    $0 -s coding                    # Run coding suite
    $0 -t coding/create_mcp_server  # Run specific task
    $0 -s coding -n 5               # Run coding suite with 5 trials

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--suite)
            SUITE="$2"
            shift 2
            ;;
        -t|--task)
            TASK="$2"
            shift 2
            ;;
        -n|--trials)
            TRIALS="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check if we're in a project with evals
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

if [ ! -d "evals" ]; then
    echo -e "${RED}Error: evals/ directory not found${NC}"
    echo "Make sure you're in an Agent project with evaluation framework set up."
    exit 1
fi

if [ ! -f "evals/harness.py" ]; then
    echo -e "${RED}Error: evals/harness.py not found${NC}"
    echo "Make sure the evaluation framework is properly initialized."
    exit 1
fi

cd evals

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}       Agent Evaluation Runner          ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Build command
CMD="python harness.py"

if [ -n "$SUITE" ]; then
    CMD="$CMD --suite $SUITE"
    echo -e "${YELLOW}Suite:${NC} $SUITE"
fi

if [ -n "$TASK" ]; then
    CMD="$CMD --task $TASK"
    echo -e "${YELLOW}Task:${NC} $TASK"
fi

CMD="$CMD --trials $TRIALS"
echo -e "${YELLOW}Trials:${NC} $TRIALS"

CMD="$CMD --config $CONFIG"
echo -e "${YELLOW}Config:${NC} $CONFIG"

echo ""
echo -e "${BLUE}----------------------------------------${NC}"
echo ""

# Run evaluation
if [ "$VERBOSE" = true ]; then
    $CMD
else
    $CMD 2>&1 | grep -v "^DEBUG" || true
fi

# Check results
RESULTS_FILE="results/latest.json"
if [ -L "$RESULTS_FILE" ] && [ -f "$RESULTS_FILE" ]; then
    echo ""
    echo -e "${BLUE}----------------------------------------${NC}"
    echo ""
    
    # Parse results
    if command -v python3 &> /dev/null; then
        python3 << PYEOF
import json
import sys

try:
    with open("$RESULTS_FILE") as f:
        data = json.load(f)
    
    summary = data.get("summary", {})
    overall_pass = summary.get("overall_pass_rate", 0)
    overall_score = summary.get("overall_avg_score", 0)
    total_tasks = summary.get("total_tasks", 0)
    
    print(f"\033[1mResults Summary:\033[0m")
    print(f"  Total Tasks: {total_tasks}")
    print(f"  Overall Pass Rate: {overall_pass:.1%}")
    print(f"  Overall Avg Score: {overall_score:.2f}")
    print("")
    
    # Color code the result
    if overall_pass >= 0.8:
        print(f"\033[0;32m✅ Evaluation PASSED\033[0m")
        sys.exit(0)
    elif overall_pass >= 0.5:
        print(f"\033[1;33m⚠️  Evaluation PARTIAL\033[0m")
        sys.exit(0)
    else:
        print(f"\033[0;31m❌ Evaluation FAILED\033[0m")
        sys.exit(1)
        
except Exception as e:
    print(f"Error parsing results: {e}")
    sys.exit(1)
PYEOF
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
