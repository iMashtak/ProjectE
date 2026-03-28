#!/usr/bin/python3

import sys
import os
import json
import argparse

root = os.path.dirname(os.path.abspath(__file__))


def handle_gen_manifest():
    with open(os.path.join(root, "manifest.json"), 'r') as f:
        manifest = json.load(f)
    result = []
    result.append(f"## Title: {manifest['title']}\n")
    result.append(f"## Description: {manifest['description']}\n")
    result.append(f"## Author: {manifest['author']}\n")
    result.append(f"## Version: {manifest['version']}\n")
    result.append(f"## APIVersion: {manifest['api_version']}\n")
    result.append("\n")
    
    def iterative_topological_sort(graph, start):
        seen = set()
        stack = []
        order = []
        q = [start]
        while q:
            v = q.pop()
            if v not in seen:
                seen.add(v)
                q.extend(graph[v])
                while stack and v not in graph[stack[-1]]:
                    order.append(stack.pop())
                stack.append(v)
        return stack + order[::-1]

    src = os.path.join(root, "src")
    deps = {}
    for directory, _, files in os.walk(src):
        if len(files) == 0:
            continue
        for file in files:
            if not file.endswith(".lua") or file == "_.lua":
                continue
            file_path = os.path.join(directory, file)
            file_path = file_path.replace(root, "").removeprefix("/")
            if file_path not in deps:
                deps[file_path] = ["$"]
            with open(file_path, 'r') as f:
                while True:
                    line = f.readline()
                    if not line.startswith("--*"):
                        break
                    parts = line.split(" ")
                    if parts[1] == "use":
                        dep_path = parts[2].strip()
                        if os.path.isabs(dep_path):
                            dep_path = os.path.abspath(os.path.join(src, dep_path.removeprefix("/")))
                        else:
                            dep_path = os.path.abspath(os.path.join(directory, dep_path))
                        dep_path = dep_path.replace(root, "").removeprefix("/")
                        if file_path in deps:
                            deps[file_path].append(dep_path)
                        else:
                            deps[file_path] = [dep_path]
                    else:
                        print("unknown command:", parts[1])
                        return 1
    graph = {}
    for left, rights in deps.items():
        if left not in graph:
            graph[left] = []
        for right in rights:
            if right not in graph:
                graph[right] = [left]
            else:
                graph[right].append(left)
    deps_list: list[str] = iterative_topological_sort(graph, "$")[1:]
    for dep in deps_list:
        dep = dep.replace("/", "\\")
        result.append(f"{dep}\n")
    with open(os.path.join(root, "ProjectE.txt"), "w") as f:
        f.writelines(result)
    return 0


parser = argparse.ArgumentParser()
parser.add_argument("action")
parser.add_argument("object")
args = parser.parse_args()
if args.action == "gen":
    if args.object == "manifest":
        sys.exit(handle_gen_manifest())
    else:
        print(f"unknown object '{args.object}' for action '{args.action}', expected: 'manifest'")
else:
    print(f"unknown action '{args.action}', expected: 'gen'")
sys.exit(1)