FROM jupyter/base-notebook:python-3.11

# Install common data analysis libraries
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    scipy \
    notebook \
    ipywidgets
