from setuptools import setup, find_packages

setup(
    name="fiicode-recommendations-api",
    description="API for recommendations.",
    version="0.0.0",
    author="Team Evian",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "fastapi == 0.63.0",
        "Flask == 1.1.4",
        "Flask-PyMongo == 2.3.0",
        "pymongo[srv] == 3.11.3",
        "pydantic == 1.8.1",
        "MarkupSafe == 2.0.1",
        "scikit-learn == 1.4.0",
        "tensorflow == 2.16.1"
    ],
)